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
  head "https://github.com/RobotLocomotion/libbot2.git"

  stable do
    url "https://drake-homebrew.csail.mit.edu/mirror/libbot2-0.0.1.20180108.tar.gz"
    sha256 "3a054e069554764b21080b4a7e9344975205f1079008e6d7f17407180f29401c"

    patch do
      # Install python files to site-packages instead of dist-packages.
      url "https://drake-homebrew.csail.mit.edu/patches/libbot2-0.0.1-python-site-packages.patch"
      sha256 "26a5f58d07c79f3d187864aaee9b9eca33d66815dcde7fae79baa3622909e272"
    end
  end

  bottle do
    root_url "https://drake-homebrew.csail.mit.edu/bottles"
    sha256 "4a6075057ef89678df5263c5b62c48f8e709b14b73a097a54d99f7181fbbe35c" => :high_sierra
    sha256 "37b71da2dba18941ed9c623afbad789eaa3a9bb77ebb6471b2c5ba514878c21c" => :sierra
    sha256 "a053cced6824a7ed5a55e561c22b922598e0d2cc21dca2a35ec89c5310130ee8" => :el_capitan
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
  depends_on "python" => :recommended
  depends_on "python3" => :optional

  def install
    args = std_cmake_args + %w[
      -DGLUT_glut_LIBRARY=/System/Library/Frameworks/GLUT.framework
      -DWITH_BOT_VIS=OFF
    ]

    if build.with?("python") && build.with?("python3")
      odie "Building with both python and python3 is NOT supported."
    elsif build.with?("python") || build.with?("python3")
      python_executable = `which python2`.strip if build.with? "python"
      python_executable = `which python3`.strip if build.with? "python3"
      args << "-DPYTHON_EXECUTABLE='#{python_executable}'"
    else
      odie "Building without either python or python3 is NOT supported."
    end

    mkdir "build" do
      system "cmake", *args, ".."
      system "make"
      system "make", "install"
    end

    inreplace "#{lib}/cmake/bot2-core/bot2-core-targets-release.cmake", prefix, opt_prefix
    inreplace "#{lib}/cmake/bot2-frames/bot2-frames-targets-release.cmake", prefix, opt_prefix
    inreplace "#{lib}/cmake/bot2-lcmgl/bot2-lcmgl-targets-release.cmake", prefix, opt_prefix
    inreplace "#{lib}/cmake/bot2-param/bot2-param-targets-release.cmake", prefix, opt_prefix
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
  end
end
