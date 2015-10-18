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
	printf("Code to blur parts of image. Give the current block number and total number of blocks.\n");
	printf("Usage as follows: %s InputFileName OutputFileName MaskWidth PeakWidth BlockNr NrBlocks\n",name);
	exit(1);
}

int main (int argc, char *argv[]){
	if (argc != 7) usage(argv[0]);
	int width, height;
	char *name = argv[1];
	char *out = argv[2];
	int mask_width = atoi(argv[3]);
	double peak_width = atof(argv[4]);
	int blockNr = atoi(argv[5]);
	int nrBlocks = atoi(argv[6]);
	char outname[2048];
	sprintf(outname,"%s_part%d",out,blockNr);
	if (mask_width%2 !=1){
		printf("Mask width must be odd.\n");
		exit(1);
	}
	
	//char command[2048], command2[2048];
	//sprintf(command,"ssh pi@192.168.1.2 raspistill -o %s",name);
	//system(command);
	//sprintf(command2,"scp pi@192.168.1.2:~/%s .",name);
	//system(command2);
	
	double tStart = cpuSecond();
	
	FILE *infile = fopen(name,"rb");
	FILE *outfile = fopen(outname,"wb");
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
	int blockSize = height / nrBlocks;
	
	unsigned char *pic, *outpic;
	pic = malloc(width*height*3*sizeof(pic));
	outpic = malloc(width*height*3*sizeof(outpic));
	pJpegBuffer = (*cinfo.mem->alloc_sarray) ((j_common_ptr) &cinfo, JPOOL_IMAGE, row_stride, 1);
	//printf("%d %d\n",width,height);
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
	mask = malloc(mask_width*mask_width*sizeof(mask));
	int x,y,xcen=mask_width/2,ycen=xcen;
	double a = 1/(peak_width*peak_width * 44/7), sum=0;
	for (int i=0;i<mask_width*mask_width;i++){
		x = i%mask_width;
		y = i/mask_width;
		mask[i] = a * exp(-(x-xcen)*(x-xcen)/(2*peak_width*peak_width)
					      -(y-ycen)*(y-ycen)/(2*peak_width*peak_width));
		sum+=mask[i];
		//printf("%lf ",mask[i]);
	}
	//printf("\n%lf, %lf\n",sum, a);
	
	int pos;
	double sumout[3];
	
	int startRowNr, endRowNr;
	startRowNr = ( blockNr == 1 ) ? mask_width/2 : blockSize*(blockNr-1);
	endRowNr = ( blockNr == nrBlocks) ? height - mask_width/2 : blockSize*blockNr;
	printf("%d %d %d\n",blockNr,startRowNr,endRowNr);
	
	for (int row = startRowNr; row < endRowNr; row ++){
		for (int col= mask_width/2; col < width - mask_width/2; col++){
			sumout[0] = 0;
			sumout[1] = 0;
			sumout[2] = 0;
			for (int i=0;i<mask_width*mask_width;i++){
				x = i%mask_width + col - mask_width/2;
				y = i/mask_width + row - mask_width/2;
				pos = (y*width + x)*3;
				sumout[0]+=(double)(*(pic+pos  )) * mask[i];
				sumout[1]+=(double)(*(pic+pos+1)) * mask[i];
				sumout[2]+=(double)(*(pic+pos+2)) * mask[i];
			}
			pos = (row*width + col)*3;
			*(outpic+pos) = (unsigned char) sumout[0];
			*(outpic+pos+1) = (unsigned char) sumout[1];
			*(outpic+pos+2) = (unsigned char) sumout[2];
			//printf("%d %d %d %d %d %d\n",(int)pic[pos],(int)pic[pos+1],(int)pic[pos+2],
			//(int)outpic[pos],(int)outpic[pos+1],(int)outpic[pos+2]);
		}
	}
	outpic += blockSize*(blockNr-1)*3*width;
	
	// Output file structure
	cinfo1.err = jpeg_std_error(&jerr);
	jpeg_create_compress(&cinfo1);
	jpeg_stdio_dest(&cinfo1, outfile);
	cinfo1.image_width = width;
	cinfo1.image_height = height/nrBlocks;
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
	
	printf("Block number %d out of %d, time elapsed: %lf seconds.\n",blockNr,nrBlocks,tFinish-tStart);
}
