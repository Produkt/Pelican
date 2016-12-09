#
# Be sure to run `pod lib lint Zip.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Pelican"
  s.version          = "0.0.1"
  s.summary          = "Utility class for compressing/decompressing files on iOS and Mac."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description      = <<-DESC
                      Pelican is a simple utility class for compressing/decompressing files on iOS and Mac.
                     DESC

  s.homepage         = "https://github.com/Produkt/Pelican"
  s.license          = { :type => 'GPL', :file => 'LICENSE' }
  s.author           = { 'Daniel Garcia' => 'fillito@gmail.com' }
  s.source           = { :git => 'https://github.com/Produkt/Pelican.git', :tag => "v#{s.version}" }

  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'
  s.osx.deployment_target = '10.9'
  s.requires_arc = true
  s.libraries = 'z'

  s.source_files = 'src/*.{swift,h}',
                    'src/Helpers/*.{swift}',
                    'src/minizip/*.{c,h}',
                    'src/unrar/*.hpp',
                    'src/unrar/rar.cpp',
                    'src/unrar/strlist.cpp',
                    'src/unrar/strfn.cpp',
                    'src/unrar/pathfn.cpp',
                    'src/unrar/smallfn.cpp',
                    'src/unrar/global.cpp',
                    'src/unrar/file.cpp',
                    'src/unrar/filefn.cpp',
                    'src/unrar/filcreat.cpp',
                    'src/unrar/archive.cpp',
                    'src/unrar/arcread.cpp',
                    'src/unrar/unicode.cpp',
                    'src/unrar/system.cpp',
                    'src/unrar/isnt.cpp',
                    'src/unrar/crypt.cpp',
                    'src/unrar/crc.cpp',
                    'src/unrar/rawread.cpp',
                    'src/unrar/encname.cpp',
                    'src/unrar/resource.cpp',
                    'src/unrar/match.cpp',
                    'src/unrar/timefn.cpp',
                    'src/unrar/rdwrfn.cpp',
                    'src/unrar/consio.cpp',
                    'src/unrar/options.cpp',
                    'src/unrar/errhnd.cpp',
                    'src/unrar/rarvm.cpp',
                    'src/unrar/secpassword.cpp',
                    'src/unrar/rijndael.cpp',
                    'src/unrar/getbits.cpp',
                    'src/unrar/sha1.cpp',
                    'src/unrar/sha256.cpp',
                    'src/unrar/blake2s.cpp',
                    'src/unrar/hash.cpp',
                    'src/unrar/extinfo.cpp',
                    'src/unrar/extract.cpp',
                    'src/unrar/volume.cpp',
                    'src/unrar/list.cpp',
                    'src/unrar/find.cpp',
                    'src/unrar/unpack.cpp',
                    'src/unrar/headers.cpp',
                    'src/unrar/threadpool.cpp',
                    'src/unrar/rs16.cpp',
                    'src/unrar/cmddata.cpp',
                    'src/unrar/ui.cpp',
                    'src/unrar/filestr.cpp',
                    'src/unrar/recvol.cpp',
                    'src/unrar/rs.cpp',
                    'src/unrar/scantree.cpp',
                    'src/unrar/qopen.cpp',
                    'src/unrar/dll.cpp'
  s.public_header_files = 'src/*.h', 'src/unrar/raros.hpp', 'src/unrar/dll.hpp'
  s.preserve_paths  = 'src/minizip/module.modulemap',
                    'src/unrar/arccmt.cpp',
                    'src/unrar/blake2sp.cpp',
                    'src/unrar/coder.cpp',
                    'src/unrar/crypt1.cpp',
                    'src/unrar/crypt2.cpp',
                    'src/unrar/crypt3.cpp',
                    'src/unrar/crypt5.cpp',
                    'src/unrar/hardlinks.cpp',
                    'src/unrar/log.cpp',
                    'src/unrar/model.cpp',
                    'src/unrar/rarvmtbl.cpp',
                    'src/unrar/recvol3.cpp',
                    'src/unrar/recvol5.cpp',
                    'src/unrar/suballoc.cpp',
                    'src/unrar/uicommon.cpp',
                    'src/unrar/uisilent.cpp',
                    'src/unrar/ulinks.cpp',
                    'src/unrar/unpack15.cpp',
                    'src/unrar/unpack20.cpp',
                    'src/unrar/unpack30.cpp',
                    'src/unrar/unpack50.cpp',
                    'src/unrar/unpack50frag.cpp',
                    'src/unrar/unpackinline.cpp',
                    'src/unrar/uowners.cpp',
                    'src/unrar/win32stm.cpp'
  s.pod_target_xcconfig = {
                'SWIFT_INCLUDE_PATHS' => "#{File.dirname(__FILE__)}/src/minizip/** $(SRCROOT)/Pelican/src/minizip/**",
                'LIBRARY_SEARCH_PATHS' => "#{File.dirname(__FILE__)}/src/ $(SRCROOT)/Pelican/src/",
                'OTHER_LDFLAGS' => "$(inherited) -lc++",
                'OTHER_CFLAGS' => "$(inherited) -Wno-return-type -Wno-logical-op-parentheses -Wno-conversion -Wno-parentheses -Wno-unused-function -Wno-unused-variable -Wno-switch -Wno-unused-command-line-argument",
                'OTHER_CPLUSPLUSFLAGS' => "$(inherited) -DSILENT -DRARDLL $(OTHER_CFLAGS)"
  }
  s.compiler_flags = "-Xanalyzer -analyzer-disable-all-checks"
  s.dependency 'Result', '~> 3.1.0'
end
