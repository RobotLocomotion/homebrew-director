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
  url "https://drake-homebrew.csail.mit.edu/mirror/ospray-1.5.0.tar.gz"
  sha256 "782cc1f2d55f49102b0700cf1ebb469478c342e1c4f925bc516906786dec8b0f"
  head "https://github.com/ospray/ospray.git"

  bottle do
    cellar :any
    root_url "https://drake-homebrew.csail.mit.edu/bottles"
    sha256 "17434354a6d211d9fe4ad46da65d0f6dd77a5007aa8a4503a2dcea89dcab1edc" => :high_sierra
    sha256 "34efa494daea39dd210e2f23bcd926db8ecee2c9cbdc2fe21daf1086f842cc81" => :sierra
    sha256 "58d274cd68911db9f37ffe519d99c53fbfcf4b34bf0d533174a7e9908a6fda69" => :el_capitan
  end

  needs :cxx11

  depends_on "cmake" => :build
  depends_on "embree@2"
  depends_on "ispc" => :build
  depends_on "tbb"

  def install
    args = std_cmake_args + %W[
      -Dembree_DIR=#{Formula["embree@2"].opt_lib}/cmake/embree-2.17.4"
      -DOSPRAY_ENABLE_APPS=OFF
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
        assert(OSPRAY_VERSION_MINOR == 5);
        assert(OSPRAY_VERSION_PATCH == 0);
        return 0;
      }
    EOS

    system ENV.cxx, "-std=c++11", "version.cpp", "-I#{opt_include}"
    system "./a.out"
  end
end
