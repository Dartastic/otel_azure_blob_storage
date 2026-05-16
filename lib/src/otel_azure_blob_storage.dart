// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_azure_blob_storage_suppression.dart';

const _tracerName = 'dartastic_otel_libs_azure_blob_storage';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class AzureBlobStorageResult {
  const AzureBlobStorageResult({
    this.account,
    this.endpoint,
    this.container,
    this.blob,
    this.blobKind,
    this.tier,
    this.contentType,
    this.sizeBytes,
    this.bytesTransferred,
    this.etag,
    this.leaseState,
    this.leaseStatus,
    this.versionId,
    this.snapshot,
    this.encryptionScope,
    this.cmkKeyName,
    this.cpkSha256,
    this.copyStatus,
    this.copyProgress,
    this.sasMethod,
    this.sasExpiresSec,
    this.requestId,
    this.serverErrorCode,
    this.statusCode,
  });

  /// Storage account name.
  final String? account;

  /// Resolved endpoint (`<account>.blob.core.windows.net`).
  final String? endpoint;

  final String? container;
  final String? blob;

  /// `BlockBlob`, `PageBlob`, `AppendBlob`.
  final String? blobKind;

  /// `Hot`, `Cool`, `Cold`, `Archive`.
  final String? tier;

  final String? contentType;
  final int? sizeBytes;
  final int? bytesTransferred;

  final String? etag;

  /// `available`, `leased`, `expired`, `breaking`, `broken`.
  final String? leaseState;

  /// `locked`, `unlocked`.
  final String? leaseStatus;

  final String? versionId;
  final String? snapshot;

  final String? encryptionScope;

  /// Customer-managed key (CMK) name.
  final String? cmkKeyName;

  /// Customer-provided key SHA-256 (CPK).
  final String? cpkSha256;

  /// `pending`, `success`, `aborted`, `failed`.
  final String? copyStatus;

  /// `bytesCopied/totalBytes`.
  final String? copyProgress;

  /// Account key signature method (`HMAC-SHA256`) or `account_sas`,
  /// `user_delegation_sas`, `service_sas`.
  final String? sasMethod;
  final int? sasExpiresSec;

  /// Server-assigned `x-ms-request-id`.
  final String? requestId;

  /// `x-ms-error-code` (e.g. `BlobNotFound`, `ContainerNotFound`,
  /// `AuthenticationFailed`, `ServerBusy`, `LeaseAlreadyPresent`,
  /// `InvalidRange`, `ConditionNotMet`, `BlobAlreadyExists`).
  final String? serverErrorCode;

  final int? statusCode;
}

class AzureBlobStorageCallResult<T> {
  const AzureBlobStorageCallResult({required this.value, this.result});
  final T value;
  final AzureBlobStorageResult? result;
}

/// Wraps an Azure Blob Storage call in a CLIENT span. [operation] is one
/// of `service.getProperties`, `service.setProperties`,
/// `service.getAccountInfo`, `service.findBlobsByTags`,
/// `service.getUserDelegationKey`, `container.create`, `container.delete`,
/// `container.getProperties`, `container.setMetadata`,
/// `container.getAccessPolicy`, `container.setAccessPolicy`,
/// `container.listBlobs`, `container.acquireLease`,
/// `container.releaseLease`, `container.breakLease`,
/// `blob.upload`, `blob.uploadStream`, `blob.download`,
/// `blob.downloadToFile`, `blob.delete`, `blob.deleteIfExists`,
/// `blob.getProperties`, `blob.setProperties`, `blob.setMetadata`,
/// `blob.setTier`, `blob.snapshot`, `blob.startCopyFromUrl`,
/// `blob.abortCopyFromUrl`, `blob.acquireLease`, `blob.releaseLease`,
/// `blob.renewLease`, `blob.breakLease`, `blob.exists`,
/// `blob.generateSasUrl`, `blockBlob.stageBlock`,
/// `blockBlob.commitBlockList`, `blockBlob.getBlockList`,
/// `pageBlob.uploadPages`, `pageBlob.resize`, `pageBlob.clearPages`,
/// `appendBlob.appendBlock`, `dataLake.getPaths`.
Future<T> tracedAzureBlobStorage<T>({
  required String operation,
  required Future<AzureBlobStorageCallResult<T>> Function() invoke,
}) async {
  if (azureBlobStorageInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'azure_blob_storage',
    'rpc.method': operation,
    'azure_blob_storage.operation': operation,
  };

  final span = _tracer().startSpan(
    'azure_blob_storage $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.account != null) {
        extras.add(OTel.attributeString(
          'azure_blob_storage.account',
          res.account!,
        ));
      }
      if (res.endpoint != null) {
        extras.add(OTel.attributeString(
          'azure_blob_storage.endpoint',
          res.endpoint!,
        ));
      }
      if (res.container != null) {
        extras.add(OTel.attributeString(
          'azure_blob_storage.container',
          res.container!,
        ));
      }
      if (res.blob != null) {
        extras.add(OTel.attributeString('azure_blob_storage.blob', res.blob!));
      }
      if (res.blobKind != null) {
        extras.add(OTel.attributeString(
          'azure_blob_storage.blob.kind',
          res.blobKind!,
        ));
      }
      if (res.tier != null) {
        extras.add(OTel.attributeString(
          'azure_blob_storage.tier',
          res.tier!,
        ));
      }
      if (res.contentType != null) {
        extras.add(OTel.attributeString(
          'azure_blob_storage.content_type',
          res.contentType!,
        ));
      }
      if (res.sizeBytes != null) {
        extras.add(OTel.attributeInt(
          'azure_blob_storage.size_bytes',
          res.sizeBytes!,
        ));
      }
      if (res.bytesTransferred != null) {
        extras.add(OTel.attributeInt(
          'azure_blob_storage.bytes_transferred',
          res.bytesTransferred!,
        ));
      }
      if (res.etag != null) {
        extras.add(OTel.attributeString(
          'azure_blob_storage.etag',
          res.etag!,
        ));
      }
      if (res.leaseState != null) {
        extras.add(OTel.attributeString(
          'azure_blob_storage.lease.state',
          res.leaseState!,
        ));
      }
      if (res.leaseStatus != null) {
        extras.add(OTel.attributeString(
          'azure_blob_storage.lease.status',
          res.leaseStatus!,
        ));
      }
      if (res.versionId != null) {
        extras.add(OTel.attributeString(
          'azure_blob_storage.version.id',
          res.versionId!,
        ));
      }
      if (res.snapshot != null) {
        extras.add(OTel.attributeString(
          'azure_blob_storage.snapshot',
          res.snapshot!,
        ));
      }
      if (res.encryptionScope != null) {
        extras.add(OTel.attributeString(
          'azure_blob_storage.encryption.scope',
          res.encryptionScope!,
        ));
      }
      if (res.cmkKeyName != null) {
        extras.add(OTel.attributeString(
          'azure_blob_storage.cmk.key_name',
          res.cmkKeyName!,
        ));
      }
      if (res.cpkSha256 != null) {
        extras.add(OTel.attributeString(
          'azure_blob_storage.cpk.sha256',
          res.cpkSha256!,
        ));
      }
      if (res.copyStatus != null) {
        extras.add(OTel.attributeString(
          'azure_blob_storage.copy.status',
          res.copyStatus!,
        ));
        if (res.copyStatus == 'failed' || res.copyStatus == 'aborted') {
          span.setStatus(
            SpanStatusCode.Error,
            'Blob copy ${res.copyStatus}',
          );
        }
      }
      if (res.copyProgress != null) {
        extras.add(OTel.attributeString(
          'azure_blob_storage.copy.progress',
          res.copyProgress!,
        ));
      }
      if (res.sasMethod != null) {
        extras.add(OTel.attributeString(
          'azure_blob_storage.sas.method',
          res.sasMethod!,
        ));
      }
      if (res.sasExpiresSec != null) {
        extras.add(OTel.attributeInt(
          'azure_blob_storage.sas.expires_sec',
          res.sasExpiresSec!,
        ));
      }
      if (res.requestId != null) {
        extras.add(OTel.attributeString(
          'azure_blob_storage.request.id',
          res.requestId!,
        ));
      }
      if (res.serverErrorCode != null) {
        extras.add(OTel.attributeString(
          'azure_blob_storage.error.code',
          res.serverErrorCode!,
        ));
        span.setStatus(
          SpanStatusCode.Error,
          'Blob ${res.serverErrorCode}',
        );
      }
      if (res.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          res.statusCode!,
        ));
        if (res.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Blob HTTP ${res.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
