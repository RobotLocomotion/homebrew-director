# Copyright (c) 2016, Massachusetts Institute of Technology.
# Copyright (c) 2016, Toyota Research Institute.
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
# Copyright (c) 2009-2016, Homebrew contributors.
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

class VtkAT510 < Formula
  desc "Toolkit for 3D computer graphics, image processing, and visualization"
  homepage "https://www.vtk.org/"
  revision 1
  head "https://vtk.org/VTK.git", :branch => "release-5.10"

  stable do
    url "https://drake-homebrew.csail.mit.edu/mirror/vtk-5.10.1.tar.gz"
    sha256 "f1a240c1f5f0d84e27b57e962f8e4a78b166b25bf4003ae16def9874947ebdbb"

    patch do
      # Apply upstream patches for C++11 mode.
      url "https://drake-homebrew.csail.mit.edu/patches/vtk-5.10.1-cxx11-patch.diff"
      sha256 "b5946abb41c3d6ede33df636fa1621bbb86c4092cdae7032e3fdc63a5478f03d"
    end

    patch do
      # Do not link against libpython when possible.
      url "https://drake-homebrew.csail.mit.edu/patches/vtk-5.10.1-optional-python-link.patch"
      sha256 "3e2d0ad1278750808281abc3033536ddc159cfd7e13176c28012337a82a95885"
    end

    patch do
      # Fix bug in Wrapping/Python/setup_install_paths.py: http://vtk.org/Bug/view.php?id=13699
      url "https://drake-homebrew.csail.mit.edu/patches/vtk-5.10.1-setup-install-paths-patch.diff"
      sha256 "3b37d95ddbbe8bc393011cbf0731e76572d0020c7f894f005283d31c6b648f8d"
    end
  end

  bottle do
    root_url "https://drake-homebrew.csail.mit.edu/bottles"
    sha256 "07add2bfb63fb108ff566eb31b58627256f72dfcf0a91fd895ffb5c2d7d73f09" => :high_sierra
    sha256 "93ef69770e0951b0fd033794dac4db9bdcdf5f359dd66f2e240a1db1f9ac050a" => :sierra
    sha256 "e842e386581ad205e499dd4b593e34d42f844cf4bae706d362bd56afc1d4fc6f" => :el_capitan
  end

  keg_only :versioned_formula

  option :cxx11

  depends_on "cmake" => :build
  depends_on "hdf5"
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "python@2" => :recommended
  depends_on "qt@4" => :recommended # brew tap cartr/qt4

  def install
    args = std_cmake_args + %W[
      -DBUILD_SHARED_LIBS=ON
      -DBUILD_TESTING=OFF
      -DCMAKE_INSTALL_NAME_DIR:STRING=#{opt_lib}/vtk-5.10
      -DCMAKE_INSTALL_RPATH:STRING=#{opt_lib}/vtk-5.10
      -DVTK_REQUIRED_OBJCXX_FLAGS=''
      -DVTK_USE_COCOA=ON
      -DVTK_USE_SYSTEM_EXPAT=ON
      -DVTK_USE_SYSTEM_HDF5=ON
      -DVTK_USE_SYSTEM_JPEG=ON
      -DVTK_USE_SYSTEM_LIBXML2=ON
      -DVTK_USE_SYSTEM_PNG=ON
      -DVTK_USE_SYSTEM_TIFF=ON
      -DVTK_USE_SYSTEM_ZLIB=ON
    ]

    if build.with? "qt@4"
      args << "-DVTK_USE_GUISUPPORT=ON"
      args << "-DVTK_USE_QT=ON"
      args << "-DVTK_USE_QVTK=ON"
    end

    ENV.cxx11 if build.cxx11?

    mkdir "build" do
      if build.with? "python@2"
        python_executable = `which python2`.strip

        python_prefix = `#{python_executable} -c 'import sys;print(sys.prefix)'`.chomp
        python_include = `#{python_executable} -c 'from distutils import sysconfig;print(sysconfig.get_python_inc(True))'`.chomp
        python_version = "python" + `#{python_executable} -c 'import sys;print(sys.version[:3])'`.chomp

        args << "-DVTK_WRAP_PYTHON=ON"
        args << "-DPYTHON_EXECUTABLE='#{python_executable}'"
        args << "-DPYTHON_INCLUDE_DIR='#{python_include}'"
        # CMake picks up the system's python dylib, even if we have a brewed one.
        if File.exist? "#{python_prefix}/Python"
          args << "-DPYTHON_LIBRARY='#{python_prefix}/Python'"
        elsif File.exist? "#{python_prefix}/lib/lib#{python_version}.a"
          args << "-DPYTHON_LIBRARY='#{python_prefix}/lib/lib#{python_version}.a'"
        elsif File.exist? "#{python_prefix}/lib/lib#{python_version}.dylib"
          args << "-DPYTHON_LIBRARY='#{python_prefix}/lib/lib#{python_version}.dylib'"
        else
          odie "No libpythonX.Y.{dylib|a} file found!"
        end
        # Set the prefix for the python bindings to the Cellar.
        args << "-DVTK_PYTHON_SETUP_ARGS:STRING='--prefix=#{prefix} --single-version-externally-managed --record=installed.txt'"
      end

      args << ".."
      system "cmake", *args
      system "make"
      system "make", "install"

      inreplace "#{lib}/vtk-5.10/VTKConfig.cmake",
        "#{HOMEBREW_CELLAR}/hdf5/#{Formula["hdf5"].installed_version}/include",
        Formula["hdf5"].opt_include.to_s
      if build.with? "python"
        inreplace "#{lib}/vtk-5.10/VTKConfig.cmake",
          "#{HOMEBREW_CELLAR}/python/#{Formula["python"].installed_version}/Frameworks",
          "#{Formula["python"].opt_prefix}/Frameworks"
      end
      inreplace "#{lib}/vtk-5.10/VTKConfig.cmake", prefix, opt_prefix
    end
  end

  test do
    (testpath/"Version.cpp").write <<~EOS
      #include <vtkVersion.h>
      #include <assert.h>
      int main() {
        assert(vtkVersion::GetVTKMajorVersion()==5);
        assert(vtkVersion::GetVTKMinorVersion()==10);
        return 0;
      }
    EOS

    system ENV.cxx, "Version.cpp", "-I#{opt_include}/vtk-5.10"
    system "./a.out"
  end
end
