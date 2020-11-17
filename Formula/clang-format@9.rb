# Copyright (c) 2020, Massachusetts Institute of Technology.
# Copyright (c) 2020, Toyota Research Institute.
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
#
# Copyright (c) 2009-2020, Homebrew contributors.
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

class ClangFormatAT9 < Formula
  desc "Format C, C++, Java, JavaScript, Obj-C, Protobuf, and C# code"
  homepage "https://releases.llvm.org/9.0.0/tools/clang/docs/ClangFormat.html"
  url "https://github.com/llvm/llvm-project/releases/download/llvmorg-9.0.1/llvm-9.0.1.src.tar.xz"
  mirror "https://drake-homebrew.csail.mit.edu/mirror/llvmorg-9.0.1/llvm-9.0.1.src.tar.xz"
  sha256 "00a1ee1f389f81e9979f3a640a01c431b3021de0d42278f6508391a2f0b81c9a"
  license "Apache-2.0"

  bottle do
    cellar :any_skip_relocation
    root_url "https://drake-homebrew.csail.mit.edu/bottles"
    sha256 "f2d03a8e12eb27d9306dfc6ac7420c96f8070bb147a9d2a0dbe58c4b1eafbb47" => :big_sur
    sha256 "6eb9b08d7af48cc8d4e6405a563bb549e1acf15007caa6c042194911e433a4a4" => :catalina
  end

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  uses_from_macos "libxml2" => :build
  uses_from_macos "ncurses"
  uses_from_macos "zlib"

  resource "clang" do
    url "https://github.com/llvm/llvm-project/releases/download/llvmorg-9.0.1/clang-9.0.1.src.tar.xz"
    mirror "https://drake-homebrew.csail.mit.edu/mirror/llvmorg-9.0.1/clang-9.0.1.src.tar.xz"
    sha256 "5778512b2e065c204010f88777d44b95250671103e434f9dc7363ab2e3804253"
  end

  resource "libcxx" do
    url "https://github.com/llvm/llvm-project/releases/download/llvmorg-9.0.1/libcxx-9.0.1.src.tar.xz"
    mirror "https://drake-homebrew.csail.mit.edu/mirror/llvmorg-9.0.1/libcxx-9.0.1.src.tar.xz"
    sha256 "0981ff11b862f4f179a13576ab0a2f5530f46bd3b6b4a90f568ccc6a62914b34"
  end

  def install
    (buildpath/"projects/libcxx").install resource("libcxx")
    (buildpath/"tools/clang").install resource("clang")

    mkdir "build" do
      args = std_cmake_args + ["-DLLVM_ENABLE_LIBCXX=ON"]

      system "cmake", "-G", "Ninja", *args, ".."
      system "ninja", "clang-format"

      bin.install "bin/clang-format" => "clang-format-9"
    end
  end

  test do
    (testpath/"test.c").write <<~EOS
      int         main() { \n   \t printf("hello"); }
    EOS

    assert_equal "int main() { printf(\"hello\"); }\n",
      shell_output("#{bin}/clang-format-9 -style=Google test.c")
  end
end
