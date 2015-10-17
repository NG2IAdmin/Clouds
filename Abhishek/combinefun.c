#include <stdio.h>
#include <malloc.h>
#include <stdlib.h>
#include <jpeglib.h>
#include <math.h>

int H,W;
unsigned char * jpegparts(char name[]){
	
	unsigned char r,g,b;
	int width, height;
	struct jpeg_decompress_struct cinfo;
	struct jpeg_error_mgr jerr;
	
	FILE * infile;    	/* source file */
	JSAMPARRAY pJpegBuffer;   	/* Output row buffer */
	//int row_stride;   	/* physical row width in output buffer */
	if ((infile = fopen(name, "rb")) == NULL) 
	{
		fprintf(stderr, "can't open %s\n", name);
		return 0;
	}
	printf("1\n");
	cinfo.err = jpeg_std_error(&jerr);
	jpeg_create_decompress(&cinfo);
	jpeg_stdio_src(&cinfo, infile);
	(void) jpeg_read_header(&cinfo, TRUE);
	(void) jpeg_start_decompress(&cinfo);
	int row_stride = cinfo.output_width * cinfo.output_components;
	width = cinfo.output_width;
	height = cinfo.output_height;  //value of maskwidth use in earlier code
	W=width;
	H=height;
	int outcomponents =cinfo.output_components;
		//printf("o%d\n",outcomponents);
			
	unsigned char * pic;
	pic = malloc(width*height*outcomponents*sizeof(*pic));
	printf("3\n");
	pJpegBuffer = (*cinfo.mem->alloc_sarray) ((j_common_ptr) &cinfo, 
	                                           JPOOL_IMAGE, row_stride, 1);//don't know waht is this
	printf("4\n");
	
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
	}printf("5\n");
	pic-=width*height*3*sizeof(*pic);
	
	return pic;
}

void usage(char name[]){
	printf("usage as follows: %s originalfilename outputfile partsnr\n",name);
    exit(1);      
}
int main (int argc, char *argv[]){//infile outfile partsnr 
	if(argc!=4)usage(argv[0]);
	char *name=argv[1];
	char *outname=argv[2];
	int numparts=atoi(argv[3]);
	unsigned char **pic=(unsigned char**)malloc(numparts*sizeof(**pic));  //need to check this
	
	for(int i=1;i<=numparts;i++){	
		printf("loop %d\n",i);
		char tempname[2048];
		sprintf(tempname,"%s_part%d",name,i);
		printf("%s\n",tempname);
		//tempname="image1.jpg";
		pic[i-1]=jpegparts(tempname);
	}
	FILE *outfile = fopen(outname,"wb");
	
	struct jpeg_compress_struct cinfo;
	struct jpeg_error_mgr jerr;
	JSAMPARRAY pJpegBuffer;
	
	unsigned char *outpic=malloc(W*H*numparts*numparts*sizeof(*outpic));
	
	
	int r,pos=0;
	for(int i=0;i<numparts;i++){
	for(int r=0;r<(H*W*3);r++){
		outpic[pos++]=*(*(pic+i)+r);
		}
	}	
		
	
	pos-=W*H*3*numparts*sizeof(outpic);
	// Output file structure
	cinfo.err = jpeg_std_error(&jerr);
	jpeg_create_compress(&cinfo);
	jpeg_stdio_dest(&cinfo, outfile);
	cinfo.image_width = W;
	cinfo.image_height = H*numparts;
	cinfo.input_components = 3;
	cinfo.in_color_space = JCS_RGB;
	jpeg_set_defaults(&cinfo);
	int quality = 70; 
	jpeg_set_quality(&cinfo, quality, TRUE);
	jpeg_start_compress(&cinfo, TRUE);
printf("6\n");
	JSAMPROW row_pointer[1];
	while(cinfo.next_scanline < cinfo.image_height){
		
		printf("%d %d\n",cinfo.next_scanline,cinfo.image_height);
		row_pointer[0] = &outpic[cinfo.next_scanline*W*3];
		(void) jpeg_write_scanlines(&cinfo, row_pointer, 1);
	}

	printf("7\n");
	jpeg_finish_compress(&cinfo);
	fclose(outfile);
	jpeg_destroy_compress(&cinfo);


free(pic);
free(outpic);
}
