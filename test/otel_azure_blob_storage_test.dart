// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_azure_blob_storage/otel_azure_blob_storage.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_azure_blob_storage-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('blob.upload records blob kind + size + tier', () async {
    await tracedAzureBlobStorage<String>(
      operation: 'blob.upload',
      invoke: () async => const AzureBlobStorageCallResult(
        value: 'ok',
        result: AzureBlobStorageResult(
          account: 'mystorage',
          container: 'uploads',
          blob: 'reports/2026/q1.pdf',
          blobKind: 'BlockBlob',
          tier: 'Hot',
          contentType: 'application/pdf',
          sizeBytes: 524288,
          bytesTransferred: 524288,
          requestId: 'req-1',
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('azure_blob_storage blob.upload')!);
    expect(a['azure_blob_storage.blob.kind'], 'BlockBlob');
    expect(a['azure_blob_storage.tier'], 'Hot');
    expect(a['azure_blob_storage.size_bytes'], 524288);
  });

  test('failed copy sets span error', () async {
    await tracedAzureBlobStorage<String>(
      operation: 'blob.startCopyFromUrl',
      invoke: () async => const AzureBlobStorageCallResult(
        value: 'ok',
        result: AzureBlobStorageResult(copyStatus: 'failed'),
      ),
    );
    expect(
      spans.findSpanByName('azure_blob_storage blob.startCopyFromUrl')!.status,
      SpanStatusCode.Error,
    );
  });

  test('BlobNotFound server error sets span error', () async {
    await tracedAzureBlobStorage<String>(
      operation: 'blob.getProperties',
      invoke: () async => const AzureBlobStorageCallResult(
        value: 'ok',
        result: AzureBlobStorageResult(
          serverErrorCode: 'BlobNotFound',
          statusCode: 404,
        ),
      ),
    );
    expect(
      spans.findSpanByName('azure_blob_storage blob.getProperties')!.status,
      SpanStatusCode.Error,
    );
  });

  test('suppression skips spans', () async {
    await runWithoutAzureBlobStorageInstrumentationAsync(() async {
      await tracedAzureBlobStorage<String>(
        operation: 'container.listBlobs',
        invoke: () async => const AzureBlobStorageCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('azure_blob_storage '), isEmpty);
  });
}
