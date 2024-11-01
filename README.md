# RTL Edge Detection

## Description
An entirely RTL programmable logic based implementation of the Sobel Edge detection algorithm. 
The goal was to avoid any PS interfacing purely for my own learning.

This was done on the PYNQ-Z2 board which has two HDMI interfaces.
The design takes HDMI input from a monitor or other device and passes it through the FPGA and out another HDMI port. Really it is running DVI, which is compatiable with HDMI ports.

## Project Structure
### pyz2_videoDisplay
This folder contains all source files and the project file.
Including constraints, test benches, and imported designs.

### ip_repo
Contains custom IP blocks used in the design.

### tcl_scripts
Contains scripts used to generate the project along with custom scripts developed for less GUI interfacing.

## Design

### Custom IP

### Timing and latency

## Getting Started


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

