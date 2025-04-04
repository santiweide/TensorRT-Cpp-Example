# TensorRT C/C++ Inference

This repository provides C++ and C examples that use TensorRT to inference the models that are implement with Pytorch/JAX/Tensorflow.

## Requirements

- Python 3.x | [TensorRT](https://docs.nvidia.com/deeplearning/tensorrt/install-guide/index.html#installing-tar) | PyTorch | Tensorflow | ONNX | tf2onnx | JAX | CUDA Toolkit

## Setup

1. Clone the repository:

    ```bash
    git clone https://github.com/ggluo/TensorRT-Cpp-Example.git
    cd TensorRT-Cpp-Example
    ```

2. Install onnx and tf2onnx if not:

    ```bash
    pip install onnx onnxscript tf2onnx
    ```

3. Ensure that [TensorRT](https://docs.nvidia.com/deeplearning/tensorrt/install-guide/index.html#installing-tar) and CUDA Toolkit are installed on your system and specify it according in the makefile.
    ```makefile
    LDFLAGS = -L/path/to/TensorRT/lib
    INCLUDEDIRS = -I/path/to/TensorRT/include
    ```

## Running all tests

To run the test script, execute the following commands:

```bash
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/path/to/TensorRT/lib
bash run_all.sh
```

The script [`run_all.sh`](run_all.sh) performs the following steps:

1. Exports the ONNX model: `python python/export_model.py data/model.onnx`
2. Compiles the TensorRT inference code: `make`
3. Runs the TensorRT inference code: `./main data/model.onnx data/first_engine.trt`

The provided ONNX model is located at `data/model.onnx`, and the resulting TensorRT engine will be saved to `data/first_engine.trt`.

## Overview of `main.cpp`

The `main.cpp` file contains the main entry point for the TensorRT inference code. Below is an overview of its functionality:

```cpp
#include "trt.h"
#include <iostream>

int main(int argc, char** argv) {
    std::cout << "Hello World from TensorRT" << std::endl;

    // Parse command-line arguments
    infer_params params{argv[1], 1,  argv[2], ""}; 

    // Initialize TensorRT inference object
    trt_infer trt(params);
    trt.build();

    // Copy input data from host to device
    trt.CopyFromHostToDevice({0.5f, -0.5f, 1.0f}, 0, nullptr);

    // Perform inference
    trt.infer();

    // Copy output data from device to host
    std::vector<float> output(2, 0.0f);
    trt.CopyFromDeviceToHost(output, 1, nullptr);

    // Print output
    std::cout << "Output: " << output[0] << ", " << output[1] << std::endl;

    return 0;
}
```

This code performs the following steps:

1. Initializes the TensorRT inference parameters using command-line arguments.
2. Initializes the TensorRT inference object and builds the inference engine.
3. Copies input data from the host to the device.
4. Performs inference.
5. Copies output data from the device to the host.
6. Prints the output.

## Export models

The folder [`python`](python) includes scripts for exporting models, which are created with Pytorch/JAX/Tensorflow, to `onnx` format. You can customize them for exporting your own models if needed.

## TODO
- [ ] memory leakage check with valgrind
- [x] add c_connector
- [x] load engine from file
- [x] gaussian blur

## TensorRT环境搭建-UCPH专用


贵UCPH无法使用root权限装东西，所以只能手动下载rpm然后解压了，

```bash
 wget https://developer.nvidia.com/downloads/compute/machine-learning/tensorrt/10.9.0/local_repo/nv-tensorrt-local-repo-rhel8-10.9.0-cuda-11.8-1.0-1.x86_64.rpm
rpm2cpio nv-tensorrt-local-repo-rhel8-10.9.0-cuda-11.8.rpm | cpio -idmv
rpm2cpio ./var/nv-tensorrt-local-repo-rhel8-10.9.0-cuda-11.8/*.rpm | cpio -idmv
```

这一顿操作完了之后，trt lib目录位于：
```
/home/workspace/trt12.8/usr/lib64
```

trtexec位于：
```
/home/workspace/trt10.9/usr/src/tensorrt/bin/trtexec
```

于是
```
LDFLAGS = -L/home/workspace/trt10.9/usr/lib64
INCLUDEDIRS = -I/home/workspace/trt10.9/TensorRT/include
```

```
module load gcc
module load cuda
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/workspace/trt10.9/usr/lib64
bash run_all.sh
```

```
/usr/bin/ld: cannot find -lnvinfer
/usr/bin/ld: cannot find -lnvonnxparser
/usr/bin/ld: cannot find -lnvinfer_plugin
collect2: error: ld returned 1 exit status
make: *** [Makefile:34: main] Error 1
```
