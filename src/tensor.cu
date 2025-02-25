#include "model.h"


/* [Tensor Structure] */
/* Tensor
 * @brief - A multi-dimensional matrix containing elements of a single data
 type.
 * @member - buf  : Data buffer containing elements
 * @member - shape: Shape of tensor from outermost dimension to innermost
 dimension e.g., {{1.0, -0.5, 2.3}, {4.3, 5.6, -7.8}} => shape = {2, 3}
 */

 // 생성자: 기본 버전
Tensor::Tensor(const vector<size_t> &shape_) {
  ndim = shape_.size();
  for (size_t i = 0; i < ndim; i++) { shape[i] = shape_[i]; }
  size_t N_ = num_elem();
  //CHECK_CUDA(cudaMalloc((void**)&buf, sizeof(float) * N_)); // paged - Segmentation fault (core dumped)
  CHECK_CUDA(cudaMallocHost((void**)&buf, sizeof(float) * N_)); // pinned
  CHECK_CUDA(cudaMemset(buf, 0, sizeof(float) * N_));
}

// 생성자: 기존 버퍼 사용
Tensor::Tensor(const vector<size_t> &shape_, float *buf_) {
  ndim = shape_.size();
  for (size_t i = 0; i < ndim; i++) { shape[i] = shape_[i]; }
  size_t N_ = num_elem();
  //CHECK_CUDA(cudaMalloc((void**)&buf, sizeof(float) * N_)); // paged - Segmentation fault (core dumped)
  CHECK_CUDA(cudaMallocHost((void**)&buf, sizeof(float) * N_)); // pinned
  CHECK_CUDA(cudaMemcpy(buf, buf_, N_ * sizeof(float), cudaMemcpyHostToDevice));
}

// Tensor 소멸자
Tensor::~Tensor() {
  //if (buf != nullptr) CHECK_CUDA(cudaFree(buf)); // paged - Segmentation fault (core dumped)
  if (buf != nullptr) CHECK_CUDA(cudaFreeHost(buf));
}

// 텐서의 총 원소 개수를 반환하는 함수
size_t Tensor::num_elem() {
  size_t size = 1;
  for (size_t i = 0; i < ndim; i++) { size *= shape[i]; }
  return size;
}