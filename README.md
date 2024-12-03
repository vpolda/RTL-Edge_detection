# RTL Edge Detection

## Description
A design focused on live video editing with the implementation of the Sobel Edge detection algorithm. 

The focus is own scalability and reusability in the modules I create and test. I wanted to focus on a system that can swap in different kernels or video effects, and even adding multiple to one input stream.

The RTL Edge Detection design takes in live video streaming data, and transforms it via kernel operations. 
The challenge of this design is that the sobel kernel requires pixels from other lines, so the video data must be buffered before it is modified. I wanted to make the design capable of having multiple process like blurring on top of the sobel. This increased the complexity significantly. 
But using hardware to perform operations on live data is incredibly powerful when done with FPGA's.

This was done on the PYNQ-Z2 board.

## Requirements
### Overall design
Less than 16.67 ms for total delay (from the time needed per frame @ 720p 60Hz)

### Internal Requirements
(Mainly for my own sanity and memory)
Syncs with output Video Timing Controller

### Cool addons
Chain multiple effects together (Think this can be done with an AXI FIFO to avoid overwhelming the DMA controller)

## Project Structure
### pyz2_videoDisplay
This folder contains all source files and the project file.
Including constraints, test benches, and imported designs.

### Docs
[DECAPED] Contains LibreOffice documents pertaining to the design. Includes a Hardware Description Document detailing the design. And  block diagram presentation file for block diagram generation. 

### tcl_scripts
Contains scripts used to generate the project along with custom scripts developed for less GUI interfacing.

## Design
### Top Level
![Top wrapper](images/top_BD.PNG)
The top level design features wiring for the HDMI in and output port. Both of these are actually running DVI protocol and not HDMI. This is due to limitations of available IP for the PYNQ board and my time and development limitations. 



### DMA - Direct Memory Access
Initially, as stated above, the plan was to use only store a few rows of pixels instead of an entire frame. That was changed mainly for scalability and future growth. Instead of redoing multiple tracks of FIFO's, line buffers and kernelizers, the design would have a whole image to work on. 

This opened me to the world of DMA. Sadly the PYNQ-Z2 board has no PL to DDR controller wiring, so I had to instantiate the PS for passing along memory mapped data into the external 512 MB DDR.

The design features VDMA (video DMA) IP block for writing in the DDR.
However, a standard DMA block reads from the DDR. This is due to the need for certain pixels in the frame to be read out, instead of the entire frame. 

### Timing and latency

### Resets

### Memory

## Development Plan
(reference Sim files and AXI VIP here too)

### Crawl
Implement a simple design that buffers video data into a higher clock domain and then back out

### Walk

### Run

## Getting Started
Needed: 
   A ZYNQ-7000 board with at least two interfaces for video input and output. 
   Two cables for video data. 
   A power cable for the board. 
   And finally, an ethernet cable (note: this is used to generate the system clock on the Programmable Logic).

### Setup


### Execution

## References
Implementation of the algorithm:

https://en.wikipedia.org/wiki/Sobel_operator

https://homepages.inf.ed.ac.uk/rbf/HIPR2/sobel.htm

The following are designs used in the development of my own. 

https://github.com/JeffreySamuel/canny_edge_detection_in_FPGA/blob/main/README.md

https://github.com/tharunchitipolu/sobel-edge-detector

DMA: https://logictronix.com/wp-content/uploads/2022/03/ZedBoard-Video-Frame-Buffer-Read_Write-Reference-Design-LRFD030.pdf

## Authors

Victoria Polda
www.linkedin.com/in/victoriapolda

## Version History

* 0.1
    * Initial Release

## License

MIT License

Copyright (c) 2024 Victoria Polda

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## Acknowledgments

