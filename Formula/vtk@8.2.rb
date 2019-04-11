# Copyright (c) 2019, Massachusetts Institute of Technology.
# Copyright (c) 2019, Toyota Research Institute.
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
# Copyright (c) 2009-2019, Homebrew contributors.
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

class VtkAT82 < Formula
  desc "Toolkit for 3D computer graphics, image processing, and visualization"
  homepage "https://www.vtk.org/"
  url "https://drake-homebrew.csail.mit.edu/mirror/vtk-8.2.0.tar.gz"
  sha256 "e83394561e6425a0b51eaaa355a5309e603a325e62ee5c9425ae7b7e22ab0d79"

  bottle do
    root_url "https://drake-homebrew.csail.mit.edu/bottles"
    sha256 "c450d200a3dcd771489e7534625283038758e46c963bce69b281c03b7bdaeed5" => :mojave
    sha256 "e7cb9bc0b164bb3075df1f89f629ee4bcb1394e050d8553d88bf8a435d25a7cc" => :high_sierra
  end

  keg_only :versioned_formula

  depends_on "cmake" => [:build, :test]
  depends_on "freetype"
  depends_on "glew"
  depends_on "hdf5"
  depends_on "jpeg"
  depends_on "jsoncpp"
  depends_on "libogg"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "lz4"
  depends_on "netcdf"
  depends_on "ospray@1.8"
  depends_on "python"
  depends_on "python@2"
  depends_on "qt"
  depends_on "theora"

  patch do
    url "https://drake-homebrew.csail.mit.edu/patches/vtk-8.2.0-io-movie-ogg.patch"
    sha256 "541dc51bb04beaeb7db1fe0c0a9f94684d450b4e0262af6039419ffbb1ea1d67"
  end

  patch do
    url "https://drake-homebrew.csail.mit.edu/patches/vtk-8.2.0-optional-python-link.patch"
    sha256 "14a8814b9ed14bf0956351c0f5dfeddf3e4d74baf26dc85397085a97e1a64b2a"
  end

  patch do
    url "https://drake-homebrew.csail.mit.edu/patches/vtk-8.2.0-rendering-ospray.patch"
    sha256 "fe59899fdeaccb64abfa1c526cb6e8ebd3928dab012de5022e116700211442f0"
  end

  def install
    # vtkPython.cmake will reference python@2.
    ["python", "python@2"].each do |python|
      if python == "python"
        python_executable = `which python3`.strip
      else
        python_executable = `which python2`.strip
      end

      python_include_dir = `#{python_executable} -c 'from distutils import sysconfig;print(sysconfig.get_python_inc(True))'`.chomp
      python_version = "python" + `#{python_executable} -c 'import sys;print(sys.version[:3])'`.chomp
      python_prefix = `#{python_executable} -c 'import sys;print(sys.prefix)'`.chomp

      if File.exist? "#{python_prefix}/Python"
        python_library = "#{python_prefix}/Python"
      elsif File.exist? "#{python_prefix}/lib/lib#{python_version}.a"
        python_library = "#{python_prefix}/lib/lib#{python_version}.a"
      elsif File.exist? "#{python_prefix}/lib/lib#{python_version}.dylib"
        python_library = "#{python_prefix}/lib/lib#{python_version}.dylib"
      else
        odie "No libpythonX.Y.{dylib|a} file found!"
      end

      args = std_cmake_args + %W[
        -DBUILD_SHARED_LIBS=ON
        -DBUILD_TESTING=OFF
        -DCMAKE_INSTALL_NAME_DIR=#{opt_lib}
        -DCMAKE_INSTALL_RPATH=#{opt_lib}
        -DModule_vtkRenderingOSPRay=ON
        -DOSPRAY_INSTALL_DIR=#{Formula["ospray@1.8"].opt_prefix}
        -DPYTHON_EXECUTABLE='#{python_executable}'
        -DPYTHON_INCLUDE_DIR='#{python_include_dir}'
        -DPYTHON_LIBRARY='#{python_library}'
        -DVTK_ENABLE_VTKPYTHON=OFF
        -DVTK_Group_Qt=ON
        -DVTK_LEGACY_REMOVE=ON
        -DVTK_QT_VERSION=5
        -DVTK_USE_COCOA=ON
        -DVTK_USE_SYSTEM_EXPAT=ON
        -DVTK_USE_SYSTEM_FREETYPE=ON
        -DVTK_USE_SYSTEM_GLEW=ON
        -DVTK_USE_SYSTEM_HDF5=ON
        -DVTK_USE_SYSTEM_JPEG=ON
        -DVTK_USE_SYSTEM_JSONCPP=ON
        -DVTK_USE_SYSTEM_LIBXML2=ON
        -DVTK_USE_SYSTEM_LZ4=ON
        -DVTK_USE_SYSTEM_NETCDF=ON
        -DVTK_USE_SYSTEM_OGG=ON
        -DVTK_USE_SYSTEM_PNG=ON
        -DVTK_USE_SYSTEM_THEORA=ON
        -DVTK_USE_SYSTEM_TIFF=ON
        -DVTK_USE_SYSTEM_ZLIB=ON
        -DVTK_WRAP_PYTHON=ON
      ]

      mkdir "build-#{python}" do
        system "cmake", *args, ".."
        system "make"
        system "make", "install"
      end

      inreplace "#{lib}/cmake/vtk-8.2/Modules/vtkhdf5.cmake",
        "#{HOMEBREW_CELLAR}/hdf5/#{Formula["hdf5"].installed_version}/include",
        Formula["hdf5"].opt_include.to_s
      inreplace "#{lib}/cmake/vtk-8.2/Modules/vtkPython.cmake", lib, opt_lib
      inreplace "#{lib}/cmake/vtk-8.2/Modules/vtkPython.cmake",
        "#{HOMEBREW_CELLAR}/#{python}/#{Formula[python].installed_version}/Frameworks",
        "#{Formula[python].opt_prefix}/Frameworks"
      inreplace "#{lib}/cmake/vtk-8.2/VTKConfig.cmake", prefix, opt_prefix
    end
  end

  test do
    (testpath/"CMakeLists.txt").write <<~EOS
      cmake_minimum_required(VERSION 3.3 FATAL_ERROR)
      project(Distance2BetweenPoints LANGUAGES CXX)
      find_package(VTK 8.2 REQUIRED COMPONENTS vtkCommonCore CONFIG)
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

    system "cmake", "-DCMAKE_BUILD_TYPE=Debug", "-DCMAKE_VERBOSE_MAKEFILE=ON",
      "-DVTK_DIR=#{opt_lib}/cmake/vtk-8.2", "."
    system "make"
    system "./Distance2BetweenPoints"

    (testpath/"Distance2BetweenPoints.py").write <<~EOS
      import vtk
      p0 = (0, 0, 0)
      p1 = (1, 1, 1)
      assert vtk.vtkMath.Distance2BetweenPoints(p0, p1) == 3
    EOS

    ENV["PYTHONPATH"] = opt_lib/"python2.7/site-packages"
    system "python2.7", "Distance2BetweenPoints.py"
  end
end
