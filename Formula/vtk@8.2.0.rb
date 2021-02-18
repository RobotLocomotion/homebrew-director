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

class VtkAT820 < Formula
  desc "Toolkit for 3D computer graphics, image processing, and visualization"
  homepage "https://www.vtk.org/"
  url "https://drake-homebrew.csail.mit.edu/mirror/vtk-8.2.0.tar.gz"
  sha256 "e83394561e6425a0b51eaaa355a5309e603a325e62ee5c9425ae7b7e22ab0d79"
  license "BSD-3-Clause"

  bottle do
    root_url "https://drake-homebrew.csail.mit.edu/bottles"
    sha256 big_sur:  "d7fe9a3d866f49863436c262627a304531807ae7ce77b8b066c350bb2cbccb65"
    sha256 catalina: "03af08a908b6d461a616b8619516c7eff2b22d675ab2efbfc6755ba3cc2d6d22"
  end

  keg_only :versioned_formula

  depends_on "cmake" => [:build, :test]
  depends_on "ninja" => :build
  depends_on "boost"
  depends_on "double-conversion"
  depends_on "eigen"
  depends_on "fontconfig"
  depends_on "gl2ps"
  depends_on "glew"
  depends_on "hdf5"
  depends_on "jpeg"
  depends_on "jsoncpp"
  depends_on "libogg"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "lz4"
  depends_on "netcdf"
  depends_on "python@3.8"
  depends_on "qt"
  depends_on "sqlite"
  depends_on "theora"
  depends_on "xz"
  uses_from_macos "expat"
  uses_from_macos "libxml2"
  uses_from_macos "zlib"

  patch do
    url "https://drake-homebrew.csail.mit.edu/patches/vtk-8.2.0-infovis-boost-graph-algorithms.patch"
    sha256 "4e59d1b8b2c672ae571966f3f7ce8d0c66dd3844d6eb3727012dd98c9e897a25"
  end

  patch do
    url "https://drake-homebrew.csail.mit.edu/patches/vtk-8.2.0-io-movie-ogg.patch"
    sha256 "541dc51bb04beaeb7db1fe0c0a9f94684d450b4e0262af6039419ffbb1ea1d67"
  end

  patch do
    url "https://drake-homebrew.csail.mit.edu/patches/vtk-8.2.0-optional-python-link.patch"
    sha256 "14a8814b9ed14bf0956351c0f5dfeddf3e4d74baf26dc85397085a97e1a64b2a"
  end

  patch do
    url "https://drake-homebrew.csail.mit.edu/patches/vtk-8.2.0-python-3.8.patch"
    sha256 "1143e09bbad1baa2fba5507076cdad7b464b8775ff07747a95df8b5c2d699364"
  end

  patch do
    url "https://drake-homebrew.csail.mit.edu/patches/vtk-8.2.0-rendering-qt.patch"
    sha256 "ca544b56dcf96a66457493c43e0106231b9ff92902a45554c821794b11c6ff26"
  end

  def install
    inreplace "Common/Core/vtkConfigure.h.in", "@CMAKE_CXX_COMPILER@", "clang++"

    args = std_cmake_args + %W[
      -DBUILD_SHARED_LIBS:BOOL=ON
      -DBUILD_TESTING:BOOL=OFF
      -DCMAKE_INSTALL_NAME_DIR:STRING=#{opt_lib}
      -DCMAKE_INSTALL_RPATH:STRING=#{opt_lib}
      -DModule_vtkInfovisBoost:BOOL=ON
      -DModule_vtkInfovisBoostGraphAlgorithms:BOOL=ON
      -DModule_vtkRenderingFreeTypeFontConfig:BOOL=ON
      -DPYTHON_EXECUTABLE:FILEPATH=#{Formula["python@3.8"].opt_bin}/python3
      -DVTK_Group_Qt:BOOL=ON
      -DVTK_LEGACY_REMOVE:BOOL=ON
      -DVTK_PYTHON_VERSION:STRING=3
      -DVTK_QT_VERSION:STRING=5
      -DVTK_USE_COCOA:BOOL=ON
      -DVTK_USE_SYSTEM_DOUBLECONVERSION:BOOL=ON
      -DVTK_USE_SYSTEM_EIGEN:BOOL=ON
      -DVTK_USE_SYSTEM_EXPAT:BOOL=ON
      -DVTK_USE_SYSTEM_GL2PS:BOOL=ON
      -DVTK_USE_SYSTEM_GLEW:BOOL=ON
      -DVTK_USE_SYSTEM_HDF5:BOOL=ON
      -DVTK_USE_SYSTEM_JPEG:BOOL=ON
      -DVTK_USE_SYSTEM_JSONCPP:BOOL=ON
      -DVTK_USE_SYSTEM_LIBXML2:BOOL=ON
      -DVTK_USE_SYSTEM_LZ4:BOOL=ON
      -DVTK_USE_SYSTEM_LZMA:BOOL=ON
      -DVTK_USE_SYSTEM_NETCDF:BOOL=ON
      -DVTK_USE_SYSTEM_OGG:BOOL=ON
      -DVTK_USE_SYSTEM_PNG:BOOL=ON
      -DVTK_USE_SYSTEM_SQLITE:BOOL=ON
      -DVTK_USE_SYSTEM_THEORA:BOOL=ON
      -DVTK_USE_SYSTEM_TIFF:BOOL=ON
      -DVTK_USE_SYSTEM_ZLIB:BOOL=ON
      -DVTK_WRAP_PYTHON:BOOL=ON
    ]

    mkdir "build" do
      system "cmake", "-G", "Ninja", *args, ".."
      system "ninja"
      system "ninja", "install"
    end

    inreplace Dir["#{lib}/cmake/**/vtkhdf5.cmake"].first,
      Formula["hdf5"].prefix.realpath, Formula["hdf5"].opt_prefix
    inreplace Dir["#{lib}/cmake/**/Modules/vtkPython.cmake"].first,
      prefix.realpath, opt_prefix
    inreplace Dir["#{lib}/cmake/**/VTKConfig.cmake"].first,
      prefix.realpath, opt_prefix

    inreplace Dir["#{lib}/cmake/**/vtkexpat.cmake"].first,
      %r{;/Library/Developer/CommandLineTools[^"]*}, ""
    inreplace Dir["#{lib}/cmake/**/vtklibxml2.cmake"].first,
      %r{;/Library/Developer/CommandLineTools[^"]*}, ""
    inreplace Dir["#{lib}/cmake/**/vtkpng.cmake"].first,
      %r{;/Library/Developer/CommandLineTools[^"]*}, ""
    inreplace Dir["#{lib}/cmake/**/vtkzlib.cmake"].first,
      %r{;/Library/Developer/CommandLineTools[^"]*}, ""
  end

  test do
    (testpath/"CMakeLists.txt").write <<~EOS
      cmake_minimum_required(VERSION 3.3 FATAL_ERROR)
      project(Distance2BetweenPoints LANGUAGES CXX)
      find_package(VTK REQUIRED COMPONENTS vtkCommonCore CONFIG)
      include(${VTK_USE_FILE})
      add_executable(Distance2BetweenPoints Distance2BetweenPoints.cxx)
      target_link_libraries(Distance2BetweenPoints PRIVATE ${VTK_LIBRARIES})
    EOS

    (testpath/"Distance2BetweenPoints.cxx").write <<~EOS
      #include <vtkMath.h>
      #include <assert.h>
      int main() {
        double p0[3] = {0.0, 0.0, 0.0};
        double p1[3] = {1.0, 1.0, 1.0};
        assert(vtkMath::Distance2BetweenPoints(p0, p1) == 3.0);
        return 0;
      }
    EOS

    vtk_dir = Dir[opt_lib/"cmake/vtk-*"].first
    system "cmake", "-DCMAKE_BUILD_TYPE=Debug", "-DCMAKE_VERBOSE_MAKEFILE=ON",
      "-DVTK_DIR=#{vtk_dir}", "."
    system "make"
    system "./Distance2BetweenPoints"

    (testpath/"Distance2BetweenPoints.py").write <<~EOS
      import vtk
      p0 = (0, 0, 0)
      p1 = (1, 1, 1)
      assert vtk.vtkMath.Distance2BetweenPoints(p0, p1) == 3
    EOS

    system bin/"vtkpython", "Distance2BetweenPoints.py"
  end
end
