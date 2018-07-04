# Copyright (c) 2018, Massachusetts Institute of Technology.
# Copyright (c) 2018, Toyota Research Institute.
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
# 
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# 
# * Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

class EmbreeAT2 < Formula
  desc "High-performance ray tracing kernels"
  homepage "https://embree.github.io/"
  url "https://drake-homebrew.csail.mit.edu/mirror/embree-2.17.4.tar.gz"
  sha256 "2d5e145e36e9d80ec970d1a8c0c62ce0a07f80092c0f5dde62be547d13b7a7ac"
  head "https://github.com/embree/embree.git"

  bottle do
    cellar :any
    root_url "https://drake-homebrew.csail.mit.edu/bottles"
    sha256 "8a008f08bf1264c27a0e4f74bfe893079c55fdc18508b1c06758454258daccda" => :high_sierra
    sha256 "b26caad21a509abd638253015c9ea9f92acf357280eab3413ef58f3c54dfc090" => :sierra
    sha256 "40669b134637af139250365b0a1d007970d30baa61b7f7dad674a0b1d0cca52a" => :el_capitan
  end

  keg_only :versioned_formula

  env :std
  needs :cxx11

  depends_on "cmake" => :build
  depends_on "ispc" => :build
  depends_on "tbb"

  def install
    args = std_cmake_args + %w[
      -DEMBREE_TUTORIALS=OFF
    ]

    mkdir "build" do
      system "cmake", *args, ".."
      system "make"
      system "make", "install"
    end

    rm_rf "#{bin}/models"
  end

  test do
    (testpath/"version.cpp").write <<~EOS
      #include <cassert>
      #include <embree2/rtcore.h>
      int main() {
        assert(RTCORE_VERSION == 21704);
        return 0;
      }
    EOS

    system ENV.cxx, "-std=c++11", "version.cpp", "-I#{opt_include}"
    system "./a.out"
  end
end
