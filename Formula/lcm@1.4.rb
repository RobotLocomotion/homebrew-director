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

class LcmAT14 < Formula
  desc "Lightweight communications and marshalling"
  homepage "https://lcm-proj.github.io/"
  revision 1
  head "https://github.com/lcm-proj/lcm.git"

  stable do
    url "https://drake-homebrew.csail.mit.edu/mirror/lcm-1.3.95.20171103.tar.gz"
    sha256 "fd0afaf29954c26a725626b7bd24e873e303e84bb62dfcc05162be3f5ae30cd1"

    patch do
      # Use -undefined dynamic_lookup instead of linking directly to libpython.
      url "https://drake-homebrew.csail.mit.edu/patches/lcm-1.3.95-python-undefined-dynamic-lookup.patch"
      sha256 "9634fa3070732af69e03dd3a880079338d2be9071aea0ea8e13fb0c2b45a6b6f"
    end
  end

  bottle do
    cellar :any
    root_url "https://drake-homebrew.csail.mit.edu/bottles"
    sha256 "bf07bbe5f197a34f46e263f57820f7774e5754bd766f02a5124493fa69b3b32b" => :high_sierra
    sha256 "f648c3e3de48c6dda837364ec82126c22f393115921255984bbc0b008927b855" => :sierra
    sha256 "36167d994f5b176aaab3aac62c99aeb73ca01bede0daa31bbbc44128e8465ec8" => :el_capitan
  end

  keg_only :versioned_formula

  depends_on :java
  depends_on "cmake" => :build
  depends_on "glib"
  depends_on "python" => :optional
  depends_on "python@2" => :recommended

  def install
    args = std_cmake_args + %w[
      -DLCM_ENABLE_EXAMPLES=OFF
      -DLCM_ENABLE_TESTS=OFF
      -DLCM_INSTALL_M4MACROS=OFF
      -DLCM_INSTALL_PKGCONFIG=OFF
    ]

    if build.with?("python") && build.with?("python@2")
      odie "Building with both python and python@2 is NOT supported."
    elsif build.with?("python") || build.with?("python@2")
      python_executable = `which python2`.strip if build.with? "python@2"
      python_executable = `which python3`.strip if build.with? "python"
      args << "-DLCM_ENABLE_PYTHON=ON"
      args << "-DPYTHON_EXECUTABLE='#{python_executable}'"
    else
      args << "-DLCM_ENABLE_PYTHON=OFF"
    end

    mkdir "build" do
      system "cmake", *args, ".."
      system "make"
      system "make", "install"
    end
  end

  test do
    system "#{bin}/lcm-gen", "--version"
  end
end
