"""Type definitions for ZFS snapshot data structures."""

from __future__ import annotations

from typing import TypedDict


class _CreationProperty(TypedDict):
    value: str
    source: dict[str, str]


class _SnapshotProperties(TypedDict):
    creation: _CreationProperty


class _SnapshotData(TypedDict):
    name: str
    type: str
    pool: str
    createtxg: str
    dataset: str
    snapshot_name: str
    properties: _SnapshotProperties


class ZfsListResponse(TypedDict):
    output_version: dict[str, str | int]
    datasets: dict[str, _SnapshotData]
