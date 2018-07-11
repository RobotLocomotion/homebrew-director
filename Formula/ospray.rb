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

class Ospray < Formula
  desc "Ray-tracing-based rendering engine for high-fidelity visualization"
  homepage "https://www.ospray.org/"
  url "https://drake-homebrew.csail.mit.edu/mirror/ospray-1.6.1.tar.gz"
  sha256 "4ad07f729e2f5628890f7711d5a1647f7acd47793f3dc9e351e9dabe91f2d8b3"
  head "https://github.com/ospray/ospray.git"

  bottle do
    cellar :any
    root_url "https://drake-homebrew.csail.mit.edu/bottles"
    sha256 "101d7cabeeb28f2731127ed244904542b068b3ed14c7e20d92bb452f3a2db166" => :high_sierra
    sha256 "a7e5a0705c63af31fabd7ec043f84d4be55923b12ed55d63d9d4d1104dc53623" => :sierra
    sha256 "7d360cfbbba0a73dae1d453fe8a07bee3c5dba61c03921bdf992dd837b3e9851" => :el_capitan
  end

  needs :cxx11

  depends_on "cmake" => :build
  depends_on "embree"
  depends_on "ispc" => :build
  depends_on "tbb"

  def install
    ENV["HOMEBREW_OPTFLAGS"] = ""

    args = std_cmake_args + %W[
      -Dembree_DIR=#{Formula["embree"].opt_lib}/cmake/embree-3.2.0"
      -DOSPRAY_ENABLE_APPS=OFF
      -DOSPRAY_ENABLE_TESTING=OFF
    ]

    mkdir "build" do
      system "cmake", *args, ".."
      system "make"
      system "make", "install"
    end
  end

  test do
    (testpath/"version.cpp").write <<~EOS
      #include <cassert>
      #include <ospray/version.h>
      int main() {
        assert(OSPRAY_VERSION_MAJOR == 1);
        assert(OSPRAY_VERSION_MINOR == 6);
        assert(OSPRAY_VERSION_PATCH == 1);
        return 0;
      }
    EOS

    system ENV.cxx, "-std=c++11", "version.cpp", "-I#{opt_include}"
    system "./a.out"
  end
end
