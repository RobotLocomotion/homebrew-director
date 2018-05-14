# Copyright 2012-2018 Robot Locomotion Group @ CSAIL. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#  3. Neither the name of the copyright holder nor the names of its
#     contributors may be used to endorse or promote products derived from
#     this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

class KcovAT34 < Formula
  desc "Code coverage tester for compiled programs, Python, and shell scripts"
  homepage "https://simonkagstrom.github.io/kcov/"
  head "https://github.com/SimonKagstrom/kcov.git"

  stable do
    url "https://drake-homebrew.csail.mit.edu/mirror/kcov-34.tar.gz"
    sha256 "e566072df3983cb8576c1aeae440f4342b532121399e677d13533119f54c80a2"

    patch do
      url "https://drake-homebrew.csail.mit.edu/patches/kcov-34-command-line-tools.patch"
      sha256 "7e7d2df39973b1d2e98c5ab8ff6071fb0b388168376720ab237b97636ffbcdb5"
    end

    patch do
      url "https://drake-homebrew.csail.mit.edu/patches/kcov-34-lldb-engine-getcwd.patch"
      sha256 "0a4ff5747dc4174c044be99b9f3a969f86e215fa07ed084a03c9ed5ed18e7e6c"
    end
  end

  bottle do
    root_url "https://drake-homebrew.csail.mit.edu/bottles"
    sha256 "7b81f04e3f08f1e007db9b007277549720bfd0bdc9e928c213f1c6fff514aedf" => :high_sierra
    sha256 "6f1862015adef6013a9ebd4781d94a90cfb3c3c2b8a4e9d7912326ffac0ffdbe" => :sierra
    sha256 "0a4708df5a0aec521b23b6e6b5af9939072346090d3a77aa2e781f98393c3a15" => :el_capitan
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  def install
    mkdir "build" do
      system "cmake", "-DSPECIFY_RPATH=ON", *std_cmake_args, ".."
      system "make"
      system "make", "install"
    end

    MachO::Tools.change_install_name(
      "#{bin}/kcov",
      "@rpath/LLDB.framework/LLDB",
      "/Library/Developer/CommandLineTools/Library/PrivateFrameworks/LLDB.framework/LLDB",
    )
  end

  test do
    system "#{bin}/kcov", "--version"
  end
end
