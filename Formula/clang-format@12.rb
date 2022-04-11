# Copyright (c) 2021, Massachusetts Institute of Technology.
# Copyright (c) 2021, Toyota Research Institute.
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
# Copyright (c) 2009-2021, Homebrew contributors.
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

class ClangFormatAT12 < Formula
  desc "Format C, C++, Java, JavaScript, Obj-C, Protobuf, and C# code"
  homepage "https://releases.llvm.org/12.0.0/tools/clang/docs/ClangFormat.html"
  url "https://github.com/llvm/llvm-project/releases/download/llvmorg-12.0.0/llvm-12.0.0.src.tar.xz"
  mirror "https://drake-homebrew.csail.mit.edu/mirror/llvmorg-12.0.0/llvm-12.0.0.src.tar.xz"
  sha256 "49dc47c8697a1a0abd4ee51629a696d7bfe803662f2a7252a3b16fc75f3a8b50"
  license "Apache-2.0"

  bottle do
    root_url "https://drake-homebrew.csail.mit.edu/bottles"
    sha256 cellar: :any_skip_relocation, big_sur: "5d4a0530980172b2bfa46a119049d9420c95d25cdaa211d419ee1ebc54ff59bc"
    sha256 cellar: :any_skip_relocation, monterey: "a8f273d3ede33d1e1746fc5f69c4b80588c559050f6c1c9f7763a6bfdc25196a"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "2249364fc3047e3562233842db37b968c3556d1560703d1de477d3779068f264"
  end

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  uses_from_macos "libxml2" => :build
  uses_from_macos "ncurses"
  uses_from_macos "zlib"

  resource "clang" do
    url "https://github.com/llvm/llvm-project/releases/download/llvmorg-12.0.0/clang-12.0.0.src.tar.xz"
    mirror "https://drake-homebrew.csail.mit.edu/mirror/llvmorg-12.0.0/clang-12.0.0.src.tar.xz"
    sha256 "e26e452e91d4542da3ebbf404f024d3e1cbf103f4cd110c26bf0a19621cca9ed"
  end

  resource "libcxx" do
    url "https://github.com/llvm/llvm-project/releases/download/llvmorg-12.0.0/libcxx-12.0.0.src.tar.xz"
    mirror "https://drake-homebrew.csail.mit.edu/mirror/llvmorg-12.0.0/libcxx-12.0.0.src.tar.xz"
    sha256 "7dcb75ca4f6aae2c677d128460c48a57398c8b6791b77b74bea7cf9e04e7c3f1"
  end

  resource "libcxxabi" do
    url "https://github.com/llvm/llvm-project/releases/download/llvmorg-12.0.0/libcxxabi-12.0.0.src.tar.xz"
    mirror "https://drake-homebrew.csail.mit.edu/mirror/llvmorg-12.0.0/libcxxabi-12.0.0.src.tar.xz"
    sha256 "6ab8e8cd148a7d5103067e05c36e36ef36e27634fc8e73b5712853c9affe75b1"
  end

  def install
    (buildpath/"projects/libcxx").install resource("libcxx")
    (buildpath/"projects/libcxxabi").install resource("libcxxabi")
    (buildpath/"tools/clang").install resource("clang")

    mkdir "build" do
      args = std_cmake_args + ["-DLLVM_ENABLE_LIBCXX=ON"]

      system "cmake", "-G", "Ninja", *args, ".."
      system "ninja", "clang-format"

      bin.install "bin/clang-format" => "clang-format-12"
    end
  end

  test do
    (testpath/"test.c").write <<~EOS
      int         main() { \n   \t printf("hello"); }
    EOS

    assert_equal "int main() { printf(\"hello\"); }\n",
      shell_output("#{bin}/clang-format-12 -style=Google test.c")
  end
end
