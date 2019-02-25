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
  url "https://drake-homebrew.csail.mit.edu/mirror/libbot2-0.0.1.20181025.tar.gz"
  sha256 "212fdd854c4f6ce986dcc908b276d2d30ad29a4da9f67be813d231e946a15ee2"
  head "https://github.com/RobotLocomotion/libbot2.git"
  revision 1

  bottle do
    root_url "https://drake-homebrew.csail.mit.edu/bottles"
    sha256 "d26adaadd1db3dce33f72c9beb33b11c4d64fa65dcc996631666688555102bb4" => :mojave
    sha256 "dd57cfe36ede4ae2f7c1825cadb86c4b372b36d87050e6d545aaabee7d2015f6" => :high_sierra
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "glib"
  depends_on "gtk+"
  depends_on :java
  depends_on "jpeg"
  depends_on "lcm@1.4"
  depends_on "libpng"
  depends_on "numpy"
  depends_on "pygobject"
  depends_on "pygtk"
  depends_on "python"
  depends_on "python@2"
  depends_on "scipy"
  depends_on :x11

  def install
    # bot-log2mat and bot-procman-sheriff will use python2.
    for python in ["python3", "python2"] do
      python_executable = `which #{python}`.strip

      args = std_cmake_args + %W[
        -DGLUT_glut_LIBRARY=/System/Library/Frameworks/GLUT.framework
        -DPYTHON_EXECUTABLE='#{python_executable}'
        -DWITH_BOT_VIS=OFF
      ]

      mkdir "build-#{python}" do
        system "cmake", *args, ".."
        system "make"
        system "make", "install"
      end

      inreplace "#{bin}/bot-spy", prefix, opt_prefix
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

      if python == "python2"
        inreplace "#{bin}/bot-log2mat", prefix, opt_prefix
        inreplace "#{bin}/bot-procman-sheriff", prefix, opt_prefix

        python_version = "python" + `#{python_executable} -c 'import sys;print(sys.version[:3])'`.chomp
        inreplace "#{lib}/#{python_version}/site-packages/bot_procman/build_prefix.py",
          prefix, opt_prefix
      end
    end
  end

  test do
    system "#{bin}/bot-log2mat", "-h"
  end
end
