require 'brewkit'

class TaglibExtras <Formula
  url 'http://www.kollide.net/~jefferai/taglib-extras-1.0.1.tar.gz'
  md5 'e973ca609b18e2c03c147ff9fd9e6eb8'
  homepage ''

  depends_on 'cmake'
  depends_on 'taglib'

  def install
    system "cmake . #{std_cmake_parameters}"
    system "make install"
  end
end
