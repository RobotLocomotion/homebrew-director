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

class Libbot2 < Formula
  desc "Libraries, tools, and algorithms for robotics research"
  homepage "https://github.com/RobotLocomotion/libbot2/"
  url "https://drake-homebrew.csail.mit.edu/mirror/libbot2-0.0.1.20200422.tar.gz"
  sha256 "5e36430acbedde572621de37c71f44e621285281aa198c247aba47ad3e87094f"
  license "LGPL-3.0-or-later"
  revision 1

  bottle do
    root_url "https://drake-homebrew.csail.mit.edu/bottles"
    sha256 cellar: :any, big_sur:  "3f6f1d90761b3779b55d8d6297cda2f67babaf5ea540f18575f902bed29b41a6"
    sha256 cellar: :any, catalina: "08b4fc4f40cb1d0b8d52134a6f4d6691807443e0d3ab6d476906a4fb970e3ddb"
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "glib"
  depends_on "lcm"
  depends_on "numpy"
  depends_on "openjdk"
  depends_on "python@3.9"
  depends_on "scipy"
  uses_from_macos "zlib"

  def install
    args = std_cmake_args + %W[
      -DCMAKE_INSTALL_NAME_DIR=#{opt_lib}
      -DCMAKE_INSTALL_RPATH=#{opt_lib}
      -DPYTHON_EXECUTABLE=#{Formula["python@3.9"].opt_bin}/python3
      -DWITH_BOT_VIS=OFF
    ]

    mkdir "build" do
      system "cmake", *args, ".."
      system "make"
      system "make", "install"
    end

    inreplace bin/"bot-spy", prefix, opt_prefix
    inreplace lib/"pkgconfig/bot2-core.pc", prefix, opt_prefix
    inreplace lib/"pkgconfig/bot2-frames.pc", prefix, opt_prefix
    inreplace lib/"pkgconfig/bot2-lcmgl-client.pc", prefix, opt_prefix
    inreplace lib/"pkgconfig/bot2-lcmgl-renderer.pc", prefix, opt_prefix
    inreplace lib/"pkgconfig/bot2-param-client.pc", prefix, opt_prefix
    inreplace lib/"pkgconfig/lcmtypes_bot2-core.pc", prefix, opt_prefix
    inreplace lib/"pkgconfig/lcmtypes_bot2-frames.pc", prefix, opt_prefix
    inreplace lib/"pkgconfig/lcmtypes_bot2-lcmgl.pc", prefix, opt_prefix
    inreplace lib/"pkgconfig/lcmtypes_bot2-param.pc", prefix, opt_prefix
    inreplace lib/"pkgconfig/lcmtypes_bot2-procman.pc", prefix, opt_prefix
  end

  test do
    system bin/"bot-log2mat", "-h"
  end
end
