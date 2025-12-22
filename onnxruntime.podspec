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

  # ONNX Runtime C/C++ xcframework binary dependency
  # This is the pre-built xcframework from Microsoft
  s.vendored_frameworks = 'onnxruntime.xcframework'

  # Script to download the xcframework if not present
  s.prepare_command = <<-CMD
    ONNXRUNTIME_VERSION="1.20.0"
    XCFRAMEWORK_URL="https://download.onnxruntime.ai/pod-archive-onnxruntime-c-${ONNXRUNTIME_VERSION}.zip"
    XCFRAMEWORK_ZIP="pod-archive-onnxruntime-c-${ONNXRUNTIME_VERSION}.zip"
    EXPECTED_CHECKSUM="50891a8aadd17d4811acb05ed151ba6c394129bb3ab14e843b0fc83a48d450ff"
    
    if [ ! -d "onnxruntime.xcframework" ]; then
      echo "Downloading ONNX Runtime xcframework..."
      curl -L -o "${XCFRAMEWORK_ZIP}" "${XCFRAMEWORK_URL}"
      
      # Verify checksum
      ACTUAL_CHECKSUM=$(shasum -a 256 "${XCFRAMEWORK_ZIP}" | awk '{print $1}')
      if [ "${ACTUAL_CHECKSUM}" != "${EXPECTED_CHECKSUM}" ]; then
        echo "Checksum verification failed!"
        echo "Expected: ${EXPECTED_CHECKSUM}"
        echo "Actual: ${ACTUAL_CHECKSUM}"
        rm -f "${XCFRAMEWORK_ZIP}"
        exit 1
      fi
      
      echo "Extracting xcframework..."
      unzip -o "${XCFRAMEWORK_ZIP}"
      rm -f "${XCFRAMEWORK_ZIP}"
    fi
  CMD

  s.frameworks = 'Foundation'
end

