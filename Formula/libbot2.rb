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
  url "https://drake-homebrew.csail.mit.edu/mirror/libbot2-0.0.1.20191002.tar.gz"
  sha256 "efe09672bdcc47e8fbd8320af5e04728debc512a4313caad061f8c3da5d664c1"

  bottle do
    root_url "https://drake-homebrew.csail.mit.edu/bottles"
    sha256 "0599311fddc818014c3b6effce17b80d6ef441e104a294bc981955d5f9a69b89" => :catalina
    sha256 "ce22e96ca9f94cf526ca5edd36693c383a504f73c57fbd061147f59787a2a11f" => :mojave
    sha256 "ab15a4d268a5df203b03590aa7ae212f12483bdbb4c24757bc2e06a211b4513f" => :high_sierra
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "glib"
  depends_on :java => "1.8+"
  depends_on "lcm"
  depends_on "numpy"
  depends_on "python"
  depends_on "scipy"
  uses_from_macos "zlib"

  def install
    args = std_cmake_args + %W[
      -DCMAKE_INSTALL_NAME_DIR=#{opt_lib}
      -DCMAKE_INSTALL_RPATH=#{opt_lib}
      -DPYTHON_EXECUTABLE=#{Formula["python"].opt_bin}/python3
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
