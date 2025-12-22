Pod::Spec.new do |s|
  s.name             = 'onnxruntime-swift'
  s.version          = '1.20.0'
  s.summary          = 'ONNX Runtime Objective-C API for iOS'
  s.description      = <<-DESC
    ONNX Runtime is a cross-platform inference and training machine-learning accelerator.
    This pod provides the Objective-C API for iOS to run ONNX models.
  DESC

  s.homepage         = 'https://github.com/microsoft/onnxruntime-swift-package-manager'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Microsoft' => 'onnxruntime@microsoft.com' }
  s.source           = { :git => 'https://github.com/microsoft/onnxruntime-swift-package-manager.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'

  s.source_files = 'objectivec/**/*.{h,m,mm}'
  s.public_header_files = 'objectivec/include/*.h'

  # Exclude training-related files (matching Package.swift exclusions)
  s.exclude_files = [
    'objectivec/ReadMe.md',
    'objectivec/format_objc.sh',
    'objectivec/test/**/*',
    'objectivec/docs/**/*',
    'objectivec/ort_checkpoint.mm',
    'objectivec/ort_checkpoint_internal.h',
    'objectivec/ort_training_session_internal.h',
    'objectivec/ort_training_session.mm',
    'objectivec/include/ort_checkpoint.h',
    'objectivec/include/ort_training_session.h',
    'objectivec/include/onnxruntime_training.h'
  ]

  s.requires_arc = true
  s.library = 'c++'
  s.pod_target_xcconfig = {
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17',
    'CLANG_CXX_LIBRARY' => 'libc++',
    'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) SPM_BUILD=1'
  }

  s.user_target_xcconfig = {
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17',
    'CLANG_CXX_LIBRARY' => 'libc++'
  }

  # Depend on the official ONNX Runtime C pod instead of vendoring the xcframework
  # This avoids conflicts if other pods also use onnxruntime.xcframework
  s.dependency 'onnxruntime-c', '~> 1.20.0'

  s.frameworks = 'Foundation'
end
