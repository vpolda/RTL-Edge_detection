// Need to:
//  Configure VDMA
//  DMA read
//  DMA write

//  setup DDR

//from https://github.com/vipinkmenon/vga/blob/master/sw/vDMATest.c
#include "xparameters.h"
#include "xaxivdma.h" //for DDR
#include "xscugic.h" // for interrupts
#include "sleep.h" 
#include <stdlib.h>
#include "xil_cache.h"

#define HEIGHT 1280
#define WIDTH 720

#define BYTES_PER_PIXEL 1
#define FRAME_BUFFER_SIZE HEIGHT*WIDTH*BYTES_PER_PIXEL
#define FRAME_BUFFER_BASEADDR 0x10000000 // changed PS memory to end at 0xEFFFFF 
#define FRAME_STORE 2

static XScuGic Intc;

//Need to add writeIntrId
static int SetupIntrSystem(XAxiVdma *AxiVdmaPtr, u16 ReadIntrId);
unsigned char Buffer[FRAME_BUFFER_SIZE]; //Stores three frames


int main(){
	int status;
	int Index;

    //Can add more if desired
	//u32 Frame1_addr = 0x10000000;
    //u32 Frame2_addr = 0x10000000 + FRAME_BUFFER_SIZE;
    //u32 Frame3_addr = 0x10000000 + 2*FRAME_BUFFER_SIZE;

	//declare instance
	XAxiVdma myVDMA;
	XAxiVdma_Config *config = XAxiVdma_LookupConfig(XPAR_AXI_VDMA_0_BASEADDR);

	status = XAxiVdma_CfgInitialize(&myVDMA, config, config->BaseAddress);
    if(status != XST_SUCCESS){
    	xil_printf("DMA Initialization failed");
    }

	//setup

	XAxiVdma_DmaSetup dma_setup;

	dma_setup.VertSizeInput = HEIGHT;
	dma_setup.HoriSizeInput = WIDTH * BYTES_PER_PIXEL;
	dma_setup.Stride = WIDTH * BYTES_PER_PIXEL;
	dma_setup.FrameDelay = 1;
	dma_setup.EnableCircularBuf = 1;
	dma_setup.EnableSync = 0; // no gen lock
	dma_setup.PointNum = 1; // no gen lock
	dma_setup.EnableFrameCounter = 0; //endless
	dma_setup.FixedFrameStoreAddr = 0; /* We are not doing parking */
	//CHANGE THIS BACK ONLY FOR TEST
	dma_setup.EnableVFlip = 1; /* Enable vertical flip */ 

	//assign setup
	status = XAxiVdma_DmaConfig(&myVDMA, XAXIVDMA_READ, &dma_setup);
	if (status != XST_SUCCESS) {
		xil_printf("Read channel configuration failed\n");
		return XST_FAILURE;
	}

	status = XAxiVdma_DmaConfig(&myVDMA, XAXIVDMA_WRITE, &dma_setup);
	if (status != XST_SUCCESS) {
		xil_printf("Write channel configuration failed\n");
		return XST_FAILURE;
	}

	//Assign Buffer address
	status = XAxiVdma_DmaSetBufferAddr(&myVDMA, XAXIVDMA_READ, (u32[]){FRAME_BUFFER_BASEADDR});
		if (status != XST_SUCCESS) {
			xil_printf("Read buffer address configuration failed\n");
			return XST_FAILURE;
		}

	status = XAxiVdma_DmaSetBufferAddr(&myVDMA, XAXIVDMA_WRITE, (u32[]){FRAME_BUFFER_BASEADDR});
		if (status != XST_SUCCESS) {
			xil_printf("Write buffer address configuration failed\n");
			return XST_FAILURE;
		}


    //Assign frames to store 
	status = XAxiVdma_SetFrmStore(&myVDMA, FRAME_STORE, XAXIVDMA_READ);
		if (status != XST_SUCCESS) {
			xil_printf("Read frames to store configuration failed\n");
			return XST_FAILURE;
		}

	status = XAxiVdma_SetFrmStore(&myVDMA, FRAME_STORE, XAXIVDMA_WRITE);
		if (status != XST_SUCCESS) {
			xil_printf("Write frames to store configuration failed\n");
			return XST_FAILURE;
		}

	XAxiVdma_IntrEnable(&myVDMA, XAXIVDMA_IXR_COMPLETION_MASK, XAXIVDMA_READ);

	SetupIntrSystem(&myVDMA, XPAR_AXI_VDMA_0_INTERRUPTS);

	//Fill the data
	/*for(int i=0;i<VSize;i++){
		for(int j=0;j<HSize*3;j=j+3){
			if(j>=0 && j<640*3){
				Buffer[(i*HSize*3)+j] = 0xff;
			    Buffer[(i*HSize*3)+j+1] = 0x00;
			    Buffer[(i*HSize*3)+j+2] = 0x00;
			}
			else if(j>=640*3 && j<1280*3){
				Buffer[(i*HSize*3)+j]   = 0x00;
			    Buffer[(i*HSize*3)+j+1] = 0xff;
			    Buffer[(i*HSize*3)+j+2] = 0x00;
			}
			else {
				Buffer[(i*HSize*3)+j]   = 0x00;
			    Buffer[(i*HSize*3)+j+1] = 0x00;
			    Buffer[(i*HSize*3)+j+2] = 0xff;
			}
		}
	}*/

	Xil_DCacheFlush();

	status = XAxiVdma_DmaStart(&myVDMA,XAXIVDMA_READ);
	if (status != XST_SUCCESS) {
		if(status == XST_VDMA_MISMATCH_ERROR)
			xil_printf("DMA Mismatch Error\r\n");
		return XST_FAILURE;
	}

    while(1){
    }
}


/*****************************************************************************/
 /* Call back function for read channel
******************************************************************************/

static void ReadCallBack(void *CallbackRef, u32 Mask)
{
	static int i=0;
	/* User can add his code in this call back function */
	xil_printf("Read Call back function is called\r\n");
	if(i==0){
		memset(Buffer,0x00,FRAME_BUFFER_SIZE);
		i=1;
	}
	else{
		memset(Buffer,0xff,FRAME_BUFFER_SIZE);
		i=0;
	}
	Xil_DCacheFlush();
	sleep(1);
}

/*****************************************************************************/
/*
 * The user can put his code that should get executed when this
 * call back happens.
 *
*
******************************************************************************/
static void ReadErrorCallBack(void *CallbackRef, u32 Mask)
{
	/* User can add his code in this call back function */
	xil_printf("Read Call back Error function is called\r\n");

}


static int SetupIntrSystem(XAxiVdma *AxiVdmaPtr, u16 ReadIntrId)
{
	int Status;
	XScuGic *IntcInstancePtr =&Intc;

	/* Initialize the interrupt controller and connect the ISRs */
	XScuGic_Config *IntcConfig;
	IntcConfig = XScuGic_LookupConfig(XPAR_XSCUGIC_0_BASEADDR);
	Status =  XScuGic_CfgInitialize(IntcInstancePtr, IntcConfig, IntcConfig->CpuBaseAddress);
	if(Status != XST_SUCCESS){
		xil_printf("Interrupt controller initialization failed..");
		return -1;
	}

	Status = XScuGic_Connect(IntcInstancePtr,ReadIntrId,(Xil_InterruptHandler)XAxiVdma_ReadIntrHandler,(void *)AxiVdmaPtr);
	if (Status != XST_SUCCESS) {
		xil_printf("Failed read channel connect intc %d\r\n", Status);
		return XST_FAILURE;
	}

	XScuGic_Enable(IntcInstancePtr,ReadIntrId);

	Xil_ExceptionInit();
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,(Xil_ExceptionHandler)XScuGic_InterruptHandler,(void *)IntcInstancePtr);
	Xil_ExceptionEnable();

	/* Register call-back functions
	 */
	XAxiVdma_SetCallBack(AxiVdmaPtr, XAXIVDMA_HANDLER_GENERAL, ReadCallBack, (void *)AxiVdmaPtr, XAXIVDMA_READ);

	XAxiVdma_SetCallBack(AxiVdmaPtr, XAXIVDMA_HANDLER_ERROR, ReadErrorCallBack, (void *)AxiVdmaPtr, XAXIVDMA_READ);

	return XST_SUCCESS;
}