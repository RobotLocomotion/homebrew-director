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

class Libbot2 < Formula
  desc "Libraries, tools, and algorithms for robotics research"
  homepage "https://github.com/RobotLocomotion/libbot2/"
  url "https://drake-homebrew.csail.mit.edu/mirror/libbot2-0.0.1.20180111.tar.gz"
  sha256 "6125bccbaca3cea632b3e9bd3bf44da05623aab61e9de7d74bd0153c5f1c210e"
  head "https://github.com/RobotLocomotion/libbot2.git"

  bottle do
    root_url "https://drake-homebrew.csail.mit.edu/bottles"
    sha256 "346453e4046359f5f2faac7c8c46cd2b3205014a38dcba067e4e34aebcbfbf7a" => :high_sierra
    sha256 "ba2ac6c1f9dcb00166f62a56a676fa95c373046868029f591e25d4da79dfe202" => :sierra
    sha256 "5e6ab7a4ceadc017aaa62f1b57faf67fc0889b0cdd66e3672de87ca2c7d3fff4" => :el_capitan
  end

  depends_on :java
  depends_on :x11
  depends_on "cmake" => :build
  depends_on "glib"
  depends_on "gtk+"
  depends_on "jpeg"
  depends_on "lcm@1.4"
  depends_on "libpng"
  depends_on "pkg-config" => :build
  depends_on "pygobject"
  depends_on "pygtk"
  depends_on "python"

  def install
    python_executable = `which python2`.strip

    args = std_cmake_args + %W[
      -DGLUT_glut_LIBRARY=/System/Library/Frameworks/GLUT.framework
      -DPYTHON_EXECUTABLE='#{python_executable}'
      -DWITH_BOT_VIS=OFF
    ]

    mkdir "build" do
      system "cmake", *args, ".."
      system "make"
      system "make", "install"
    end

    python_version = "python" + `#{python_executable} -c 'import sys;print(sys.version[:3])'`.chomp

    inreplace "#{bin}/bot-log2mat", prefix, opt_prefix
    inreplace "#{bin}/bot-procman-sheriff", prefix, opt_prefix
    inreplace "#{bin}/bot-spy", prefix, opt_prefix
    inreplace "#{lib}/cmake/bot2-core/bot2-core-targets-release.cmake",
      prefix, opt_prefix
    inreplace "#{lib}/cmake/bot2-frames/bot2-frames-targets-release.cmake",
      prefix, opt_prefix
    inreplace "#{lib}/cmake/bot2-lcmgl/bot2-lcmgl-targets-release.cmake",
      prefix, opt_prefix
    inreplace "#{lib}/cmake/bot2-param/bot2-param-targets-release.cmake",
      prefix, opt_prefix
    inreplace "#{lib}/pkgconfig/bot2-core.pc", prefix, opt_prefix
    inreplace "#{lib}/pkgconfig/bot2-frames.pc", prefix, opt_prefix
    inreplace "#{lib}/pkgconfig/bot2-lcmgl-client.pc", prefix, opt_prefix
    inreplace "#{lib}/pkgconfig/bot2-lcmgl-renderer.pc", prefix, opt_prefix
    inreplace "#{lib}/pkgconfig/bot2-param-client.pc", prefix, opt_prefix
    inreplace "#{lib}/pkgconfig/lcmtypes_bot2-core.pc", prefix, opt_prefix
    inreplace "#{lib}/pkgconfig/lcmtypes_bot2-frames.pc", prefix, opt_prefix
    inreplace "#{lib}/pkgconfig/lcmtypes_bot2-lcmgl.pc", prefix, opt_prefix
    inreplace "#{lib}/pkgconfig/lcmtypes_bot2-param.pc", prefix, opt_prefix
    inreplace "#{lib}/pkgconfig/lcmtypes_bot2-procman.pc", prefix, opt_prefix
    inreplace "#{lib}/#{python_version}/site-packages/bot_procman/build_prefix.py",
      prefix, opt_prefix
  end

  test do
    system "#{bin}/bot-log2mat", "-h"
  end
end
