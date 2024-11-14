# RTL Edge Detection

## Description
An entirely RTL programmable logic based design with the implementation of the Sobel Edge detection algorithm. 
The goal was to avoid any PS interfacing purely for my own learning, while working with computer vision topics that interest me.

The RTL Edge Detection design takes in live video streaming data, and transforms it via kernel operations. This is achieved through multiple FIFOs, BRAM, and intermediate processes. 
The challenge of this design is that the sobel kernel requires pixels from other lines, so the video data must be buffered before it is modified. I wanted to make the design capable of having multiple process like blurring on top of the sobel. This increased the complexity significantly.

This was done on the PYNQ-Z2 board without the PS instantiated.

## Project Structure
### pyz2_videoDisplay
This folder contains all source files and the project file.
Including constraints, test benches, and imported designs.

### Docs
Contains LibreOffice documents pertaining to the design. Includes a Hardware Description Document detailing the design. And  block diagram presentation file for block diagram generation. 

### tcl_scripts
Contains scripts used to generate the project along with custom scripts developed for less GUI interfacing.

## Design
Please refer to /docs/Hardware_Description_Doc.pdf for more details on the design.

The RTL Edge Detection features custom IP. Each one has its design and use documented in the referrenced above doc.

### Timing and latency

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

