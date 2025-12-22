Pod::Spec.new do |s|
  s.name             = 'onnxruntime'
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

  # Use the same module name as SPM for compatibility
  s.module_name = 'OnnxRuntimeBindings'

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

  # Vendored xcframework (downloaded via prepare_command, matching Package.swift approach)
  # Renamed to onnxruntime_swift.xcframework to avoid conflicts with other pods
  s.vendored_frameworks = 'onnxruntime_swift.xcframework'
  s.preserve_paths = 'onnxruntime_swift.xcframework', 'Headers'

  s.pod_target_xcconfig = {
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17',
    'CLANG_CXX_LIBRARY' => 'libc++',
    'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) SPM_BUILD=1',
    'HEADER_SEARCH_PATHS' => '$(inherited) "${PODS_ROOT}/onnxruntime-swift/Headers"'
  }

  s.user_target_xcconfig = {
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17',
    'CLANG_CXX_LIBRARY' => 'libc++'
  }

  s.frameworks = 'Foundation'

  # Download the xcframework from Microsoft (same as Package.swift binaryTarget)
  # URL: https://download.onnxruntime.ai/pod-archive-onnxruntime-c-1.20.0.zip
  # Checksum: 50891a8aadd17d4811acb05ed151ba6c394129bb3ab14e843b0fc83a48d450ff
  s.prepare_command = <<-CMD
    set -e
    ONNXRUNTIME_VERSION="1.20.0"
    XCFRAMEWORK_URL="https://download.onnxruntime.ai/pod-archive-onnxruntime-c-${ONNXRUNTIME_VERSION}.zip"
    XCFRAMEWORK_ZIP="pod-archive-onnxruntime-c-${ONNXRUNTIME_VERSION}.zip"
    EXPECTED_CHECKSUM="50891a8aadd17d4811acb05ed151ba6c394129bb3ab14e843b0fc83a48d450ff"

    # Use a unique name to avoid conflicts with other pods that vendor onnxruntime.xcframework
    RENAMED_XCFRAMEWORK="onnxruntime_swift.xcframework"

    if [ ! -d "${RENAMED_XCFRAMEWORK}" ]; then
      echo "Downloading ONNX Runtime xcframework v${ONNXRUNTIME_VERSION}..."
      curl -L -o "${XCFRAMEWORK_ZIP}" "${XCFRAMEWORK_URL}"

      echo "Verifying checksum..."
      ACTUAL_CHECKSUM=$(shasum -a 256 "${XCFRAMEWORK_ZIP}" | awk '{print $1}')
      if [ "${ACTUAL_CHECKSUM}" != "${EXPECTED_CHECKSUM}" ]; then
        echo "ERROR: Checksum verification failed!"
        echo "Expected: ${EXPECTED_CHECKSUM}"
        echo "Actual: ${ACTUAL_CHECKSUM}"
        rm -f "${XCFRAMEWORK_ZIP}"
        exit 1
      fi
      echo "Checksum verified."

      echo "Extracting xcframework..."
      unzip -q -o "${XCFRAMEWORK_ZIP}"
      rm -f "${XCFRAMEWORK_ZIP}"

      echo "Renaming xcframework to avoid conflicts..."
      mv onnxruntime.xcframework "${RENAMED_XCFRAMEWORK}"

      echo "ONNX Runtime xcframework ready."
    else
      echo "ONNX Runtime xcframework already present."
    fi
  CMD
end
