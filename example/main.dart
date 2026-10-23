// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_azure_blob_storage/otel_azure_blob_storage.dart';

/// Traces Azure Blob Storage calls with OpenTelemetry.
///
/// `otel_azure_blob_storage` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Azure Blob Storage call in
/// [tracedAzureBlobStorage]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'azure-blob-storage-example');

  // Wraps an Azure Blob Storage call in a CLIENT span.
  final azureBlobStorageId = await tracedAzureBlobStorage<String>(
    operation: 'container.create',
    invoke: () async {
      // Make the Azure Blob Storage call here, then report what it returned.
      const id = 'azure_blob_storage_8f3a2c';
      return const AzureBlobStorageCallResult(
          value: id,
          result: AzureBlobStorageResult(
              account: 'example',
              endpoint: '<account>.blob.core.windows.net',
              container: 'example',
              blob: 'example',
              blobKind: 'BlockBlob',
              tier: 'Hot',
              contentType: 'standard',
              sizeBytes: 512,
              bytesTransferred: 512,
              etag: 'example',
              leaseState: 'available',
              leaseStatus: 'locked',
              versionId: 'version_8f3a2c',
              snapshot: 'example',
              encryptionScope: 'example',
              cmkKeyName: 'example',
              cpkSha256: 'example',
              copyStatus: 'pending',
              copyProgress: 'bytesCopied/totalBytes',
              sasMethod: 'HMAC-SHA256',
              sasExpiresSec: 1,
              requestId: 'request_8f3a2c',
              serverErrorCode: 'BlobNotFound',
              statusCode: 201));
    },
  );
  OTelLog.info(
      'tracedAzureBlobStorage container.create returned $azureBlobStorageId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutAzureBlobStorageInstrumentationAsync.
  await runWithoutAzureBlobStorageInstrumentationAsync(
    () => tracedAzureBlobStorage<String>(
      operation: 'container.create',
      invoke: () async {
        const id = 'azure_blob_storage_8f3a2c';
        return const AzureBlobStorageCallResult(
            value: id,
            result: AzureBlobStorageResult(
                account: 'example',
                endpoint: '<account>.blob.core.windows.net',
                container: 'example',
                blob: 'example',
                blobKind: 'BlockBlob',
                tier: 'Hot',
                contentType: 'standard',
                sizeBytes: 512,
                bytesTransferred: 512,
                etag: 'example',
                leaseState: 'available',
                leaseStatus: 'locked',
                versionId: 'version_8f3a2c',
                snapshot: 'example',
                encryptionScope: 'example',
                cmkKeyName: 'example',
                cpkSha256: 'example',
                copyStatus: 'pending',
                copyProgress: 'bytesCopied/totalBytes',
                sasMethod: 'HMAC-SHA256',
                sasExpiresSec: 1,
                requestId: 'request_8f3a2c',
                serverErrorCode: 'BlobNotFound',
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
