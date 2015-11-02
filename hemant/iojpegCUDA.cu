//iojpegparts.cu

#include <stdio.h>
#include <malloc.h>
#include <stdlib.h>
#include <math.h>
#include <jpeglib.h>
#include <sys/time.h>

double cpuSecond(){
	struct timeval tp;
	gettimeofday(&tp,NULL);
	return((double)tp.tv_sec + (double)tp.tv_usec*1.e-6);
}

int usage(char *name){
	printf("Code to blur parts of image using GPUs.\n");
	printf("Usage as follows: %s InputFileName OutputFileName MaskWidth PeakWidth\n",name);
	exit(1);
}

__global__ void GaussianBlurCuda (unsigned char *pic, unsigned char * outpic, double *mask, int *size){ // size: width, height, mask_width
	int pxPosCen = blockIdx.x * blockDim.x + threadIdx.x;
	if (pxPosCen >= size[0]*size[1] || pxPosCen < 0) return;
	int row, col, x, y, pos;
	row = pxPosCen/size[0]; // pixel position taken as width major
	col = pxPosCen%size[0];
	double sumout[3];
	sumout[0] = 0;
	sumout[1] = 0;
	sumout[2] = 0;
	if (row < size[2]/2 || row >= (size[1] - (size[2]/2))) return;
	if (col < size[2]/2 || col >= (size[0] - (size[2]/2))) return;
	for (int i=0;i<size[2]*size[2];i++){
		x = i%size[2] + col - size[2]/2;
		y = i/size[2] + row - size[2]/2;
		pos = (y*size[0]  + x)*3;
		sumout[0]+=(double)(*(pic+pos  )) * mask[i];
		sumout[1]+=(double)(*(pic+pos+1)) * mask[i];
		sumout[2]+=(double)(*(pic+pos+2)) * mask[i];
	}
	pos = pxPosCen*3;
	*(outpic+pos) = (unsigned char) sumout[0];
	*(outpic+pos+1) = (unsigned char) sumout[1];
	*(outpic+pos+2) = (unsigned char) sumout[2];
}


int main (int argc, char *argv[]){
	if (argc != 5) usage(argv[0]);
	int width, height;
	char *name = argv[1];
	char *out = argv[2];
	int mask_width = atoi(argv[3]);
	double peak_width = atof(argv[4]);
	if (mask_width%2 !=1){
		printf("Mask width must be odd.\n");
		exit(1);
	}

	double tStart = cpuSecond();

	FILE *infile = fopen(name,"rb");
	FILE *outfile = fopen(out,"wb");
	if (infile == NULL){
		printf("Could not read file\n");
		return 1;
	}
	struct jpeg_decompress_struct cinfo;
	struct jpeg_compress_struct cinfo1;
	struct jpeg_error_mgr jerr;
	JSAMPARRAY pJpegBuffer;

	cinfo.err = jpeg_std_error(&jerr);
	jpeg_create_decompress(&cinfo);
	jpeg_stdio_src(&cinfo, infile);
	jpeg_read_header(&cinfo, TRUE);
	jpeg_start_decompress(&cinfo);
	int row_stride = cinfo.output_width * cinfo.output_components;
	width = cinfo.output_width;
	height = cinfo.output_height;

	unsigned char *pic, *outpic;
	pic = (unsigned char *) malloc(width*height*3*sizeof(pic));
	outpic = (unsigned char *) malloc(width*height*3*sizeof(outpic));
	pJpegBuffer = (*cinfo.mem->alloc_sarray) ((j_common_ptr) &cinfo, JPOOL_IMAGE, row_stride, 1);
	while (cinfo.output_scanline < cinfo.output_height) {
		(void) jpeg_read_scanlines(&cinfo, pJpegBuffer, 1);
		for (int x=0;x<width;x++) {
			*(pic++) = pJpegBuffer[0][cinfo.output_components*x];
			if (cinfo.output_components>2){
				*(pic++) = pJpegBuffer[0][cinfo.output_components*x+1];
				*(pic++) = pJpegBuffer[0][cinfo.output_components*x+2];
			} else {
				*(pic++) = *(pic-1);
				*(pic++) = *(pic-1);
			}
		}
	}
	pic -= width*height*3;

	fclose(infile);
	(void) jpeg_finish_decompress(&cinfo);
	jpeg_destroy_decompress(&cinfo);

	double * mask;
	mask = (double *) malloc(mask_width*mask_width*sizeof(mask));
	int x,y,xcen=mask_width/2,ycen=xcen;
	double a = 1/(peak_width*peak_width * 44/7), sum=0;
	for (int i=0;i<mask_width*mask_width;i++){
		x = i%mask_width;
		y = i/mask_width;
		mask[i] = a * exp(-(x-xcen)*(x-xcen)/(2*peak_width*peak_width)
					      -(y-ycen)*(y-ycen)/(2*peak_width*peak_width));
		sum+=mask[i];
	}
	for (int i=0;i<mask_width*mask_width;i++){
		mask[i] /= sum;
	}

	// CUDA work
	cudaDeviceProp deviceProp;
    cudaGetDeviceProperties(&deviceProp,0);
    size_t gpuGlobalMem = deviceProp.totalGlobalMem;
    fprintf(stderr, "GPU global memory = %zu MBytes\n", gpuGlobalMem/(1024*1024));
    size_t freeMem, totalMem;
    cudaMemGetInfo(&freeMem, &totalMem);
    fprintf(stderr, "Free = %zu MB, Total = %zu MB\n", freeMem/(1024*1024), totalMem/(1024*1024));

	unsigned char *cudaPic, *cudaOutPic;
	double *cudaMask;
	int *sizeCuda, size[3];
	size[0] = width;
	size[1] = height;
	size[2] = mask_width;
	cudaMalloc((int **)&sizeCuda,3*sizeof(int));
	cudaMalloc((unsigned char**)&cudaPic, width*height*3*sizeof(unsigned char));
	cudaMalloc((unsigned char**)&cudaOutPic, width*height*3*sizeof(unsigned char));
	cudaMalloc((double **)&cudaMask, mask_width*mask_width*sizeof(double));
	cudaMemcpy(sizeCuda,size,3*sizeof(int),cudaMemcpyHostToDevice);
	cudaMemcpy(cudaPic,pic,width*height*3*sizeof(unsigned char),cudaMemcpyHostToDevice);
	cudaMemcpy(cudaMask,mask,mask_width*mask_width*sizeof(double),cudaMemcpyHostToDevice);
	cudaMemset(cudaOutPic,0,width*height*3*sizeof(unsigned char));

	dim3 block (1024);
	dim3 grid (((width*height)/block.x)+1);
	printf("%d %d\n",block.x, grid.x);
	GaussianBlurCuda<<<grid,block>>>(cudaPic, cudaOutPic, cudaMask, sizeCuda);
	cudaDeviceSynchronize();
	cudaMemcpy(outpic, cudaOutPic, width*height*3*sizeof(unsigned char), cudaMemcpyDeviceToHost);

	// Output file structure
	cinfo1.err = jpeg_std_error(&jerr);
	jpeg_create_compress(&cinfo1);
	jpeg_stdio_dest(&cinfo1, outfile);
	cinfo1.image_width = width;
	cinfo1.image_height = height;
	cinfo1.input_components = 3;
	cinfo1.in_color_space = JCS_RGB;
	jpeg_set_defaults(&cinfo1);
	int quality = 70;
	jpeg_set_quality(&cinfo1, quality, TRUE);
	jpeg_start_compress(&cinfo1, TRUE);

	JSAMPROW row_pointer[1];
	while(cinfo1.next_scanline < cinfo1.image_height){
		row_pointer[0] = &outpic[cinfo1.next_scanline*width*3];
		(void) jpeg_write_scanlines(&cinfo1, row_pointer, 1);
	}
	jpeg_finish_compress(&cinfo1);
	fclose(outfile);
	jpeg_destroy_compress(&cinfo1);

	double tFinish = cpuSecond();

	printf("Time elapsed: %lf seconds.\n",tFinish-tStart);
}
