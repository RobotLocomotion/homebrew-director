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
  desc "Lightweight communications and marshalling."
  homepage "https://lcm-proj.github.io/"
  url "https://drake-homebrew.csail.mit.edu/mirror/lcm-1.3.95.20171103.tar.gz"
  version "1.3.95.20171103"
  sha256 "fd0afaf29954c26a725626b7bd24e873e303e84bb62dfcc05162be3f5ae30cd1"
  head "https://github.com/lcm-proj/lcm.git"

  bottle do
    root_url "https://drake-homebrew.csail.mit.edu/bottles"
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on :java
  depends_on :python => :recommended
  depends_on :python3 => :optional
  depends_on "glib"

  def install
    args = std_cmake_args + %W[
      -DLCM_ENABLE_EXAMPLES=OFF
      -DLCM_ENABLE_TESTS=OFF
      -DLCM_INSTALL_M4MACROS=OFF
      -DLCM_INSTALL_PKGCONFIG=OFF
    ]

    if build.with?("python") && build.with?("python3")
      odie "Building with both python and python3 is NOT supported."
    elsif build.with?("python") || build.with?("python3")
      python_executable = `which python2`.strip if build.with? "python"
      python_executable = `which python3`.strip if build.with? "python3"
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
end
