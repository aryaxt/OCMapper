Pod::Spec.new do |s|
    s.platform = :ios, '5.0'
    s.name = 'OCMapper'
    s.version = '2.2'
    s.summary = 'NSDictionary to NSObject Mapper'
    s.homepage = 'https://github.com/aryaxt/OCMapper'
    s.license = {
      :type => 'MIT',
      :file => 'License.txt'
    }
    s.author = {'Aryan Ghassemi' => 'https://github.com/aryaxt/OCMapper'}
    s.source = {:git => 'https://github.com/aryaxt/OCMapper.git', :tag => '2.2'}
    s.source_files = 'OCMapper/Source/*.{h,m}','OCMapper/Source/Categories/*.{h,m}','OCMapper/Source/Logging Provider/*.{h,m}','OCMapper/Source/Instance Provider/*.{h,m}','OCMapper/Source/Mapping Provider/*.{h,m}','OCMapper/Source/Mapping Provider/In Code Mapping/*.{h,m}','OCMapper/Source/Mapping Provider/PLIST Mapping/*.{h,m}','OCMapper/Source/Mapping Provider/XML Mapping/*.{h,m}' 
    s.framework = 'Foundation'
    s.requires_arc = true
end
