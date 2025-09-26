from __future__ import annotations

import json
from datetime import UTC, datetime, timedelta, timezone
from typing import TYPE_CHECKING
from unittest.mock import Mock, patch

import pytest

from zfs_snapshot_prune.zfs_snapshot import ZfsSnapshot, ZfsSnapshotStore

if TYPE_CHECKING:
    from collections.abc import Iterable


@pytest.fixture
def mock_zfs_list_response():
    """Mock response from zfs list command."""
    return {
        "datasets": {
            "pool/dataset@snap1": {
                "name": "pool/dataset@snap1",
                "type": "SNAPSHOT",
                "dataset": "pool/dataset",
                "snapshot_name": "snap1",
                "properties": {
                    "creation": {
                        "value": "1640995200"
                    }  # 2022-01-01 00:00:00 UTC
                },
            },
            "pool/dataset@snap2": {
                "name": "pool/dataset@snap2",
                "type": "SNAPSHOT",
                "dataset": "pool/dataset",
                "snapshot_name": "snap2",
                "properties": {
                    "creation": {
                        "value": "1641081600"
                    }  # 2022-01-02 00:00:00 UTC
                },
            },
            "pool/dataset/child@snap1": {
                "name": "pool/dataset/child@snap1",
                "type": "SNAPSHOT",
                "dataset": "pool/dataset/child",
                "snapshot_name": "snap1",
                "properties": {
                    "creation": {
                        "value": "1640995200"
                    },  # 2022-01-01 00:00:00 UTC
                },
            },
        }
    }


@pytest.fixture
def sample_snapshots():
    """Create sample ZfsSnapshot objects for testing."""
    tz = UTC
    return [
        ZfsSnapshot(
            name="pool/dataset@snap1",
            dataset="pool/dataset",
            snapshot_name="snap1",
            created=datetime(2022, 1, 1, tzinfo=tz),
            is_root=True,
        ),
        ZfsSnapshot(
            name="pool/dataset@snap2",
            dataset="pool/dataset",
            snapshot_name="snap2",
            created=datetime(2022, 1, 2, tzinfo=tz),
            is_root=True,
        ),
        ZfsSnapshot(
            name="pool/dataset/child@snap1",
            dataset="pool/dataset/child",
            snapshot_name="snap1",
            created=datetime(2022, 1, 1, tzinfo=tz),
            is_root=False,
        ),
    ]


class TestZfsSnapshotStore:
    """Test cases for ZfsSnapshotStore class."""

    @patch("subprocess.run")
    @patch("zfs_snapshot_prune.zfs_snapshot.localtz", UTC)
    def test_from_dataset_non_recursive(
        self, mock_run, mock_zfs_list_response
    ):
        """Test creating ZfsSnapshotStore from dataset without recursion."""
        mock_run.return_value = Mock(
            stdout=json.dumps(mock_zfs_list_response).encode(), returncode=0
        )

        store = ZfsSnapshotStore.from_dataset(
            dataset="pool/dataset", recursive=False, offset=None, filter_=None
        )

        assert store._root_dataset == "pool/dataset"
        assert not store._is_recursive
        assert len(store._snapshots) == 3

        mock_run.assert_called_once_with(
            [
                "zfs",
                "list",
                "-t",
                "snapshot",
                "-p",
                "-o",
                "creation",
                "--json",
                "--",
                "pool/dataset",
            ],
            check=True,
            capture_output=True,
        )

    @patch("subprocess.run")
    @patch("zfs_snapshot_prune.zfs_snapshot.localtz", UTC)
    def test_from_dataset_recursive(self, mock_run, mock_zfs_list_response):
        """Test creating ZfsSnapshotStore from dataset with recursion."""
        mock_run.return_value = Mock(
            stdout=json.dumps(mock_zfs_list_response).encode(), returncode=0
        )

        store = ZfsSnapshotStore.from_dataset(
            dataset="pool/dataset", recursive=True, offset=None, filter_=None
        )

        assert store._is_recursive
        mock_run.assert_called_once_with(
            [
                "zfs",
                "list",
                "-t",
                "snapshot",
                "-p",
                "-o",
                "creation",
                "--json",
                "-r",
                "--",
                "pool/dataset",
            ],
            check=True,
            capture_output=True,
        )

    @patch("subprocess.run")
    @patch("zfs_snapshot_prune.zfs_snapshot.localtz", timezone.utc)
    def test_from_dataset_with_filter(self, mock_run, mock_zfs_list_response):
        """Test creating ZfsSnapshotStore with snapshot name filter."""
        mock_run.return_value = Mock(
            stdout=json.dumps(mock_zfs_list_response).encode(), returncode=0
        )

        store = ZfsSnapshotStore.from_dataset(
            dataset="pool/dataset",
            recursive=False,
            offset=None,
            filter_="snap1",
        )

        # Should only include snapshots matching the filter
        snap_names = {s.snapshot_name for s in store._snapshots}
        assert snap_names == {"snap1"}

    def test_apply_retention_policy_keep_last(self, sample_snapshots):
        """Test retention policy with keep_last parameter."""
        store = ZfsSnapshotStore(
            root_dataset="pool/dataset",
            snapshots=frozenset(sample_snapshots),
            by_dataset={
                "pool/dataset": frozenset(sample_snapshots[:2]),
                "pool/dataset/child": frozenset([sample_snapshots[2]]),
            },
            by_name={
                "snap1": frozenset([sample_snapshots[0], sample_snapshots[2]]),
                "snap2": frozenset([sample_snapshots[1]]),
            },
            is_recursive=False,
        )

        store.apply_retention_policy(
            keep_last=1,
            hourly_duration=None,
            daily_duration=None,
            weekly_duration=None,
            monthly_duration=None,
            yearly_duration=None,
        )

        # Most recent snapshot in each dataset should be kept
        assert (
            sample_snapshots[1].keep is True
        )  # snap2 (most recent in pool/dataset)
        assert (
            sample_snapshots[2].keep is True
        )  # snap1 (only one in pool/dataset/child)
        assert "last" in sample_snapshots[1].keep_reason
        assert "last" in sample_snapshots[2].keep_reason

    def test_apply_retention_policy_daily(self, sample_snapshots):
        """Test retention policy with daily duration."""
        store = ZfsSnapshotStore(
            root_dataset="pool/dataset",
            snapshots=frozenset(sample_snapshots),
            by_dataset={
                "pool/dataset": frozenset(sample_snapshots[:2]),
                "pool/dataset/child": frozenset([sample_snapshots[2]]),
            },
            by_name={
                "snap1": frozenset([sample_snapshots[0], sample_snapshots[2]]),
                "snap2": frozenset([sample_snapshots[1]]),
            },
            is_recursive=False,
        )

        store.apply_retention_policy(
            keep_last=0,
            hourly_duration=None,
            daily_duration=timedelta(days=3),
            weekly_duration=None,
            monthly_duration=None,
            yearly_duration=None,
        )

        # Snapshots within daily duration should be kept
        kept_snapshots = [s for s in sample_snapshots if s.keep]
        assert len(kept_snapshots) > 0

    @patch("subprocess.run")
    def test_destroy_dry_run(self, mock_run, sample_snapshots):
        """Test destroy method in dry run mode."""
        store = ZfsSnapshotStore(
            root_dataset="pool/dataset",
            snapshots=frozenset(sample_snapshots),
            by_dataset={"pool/dataset": frozenset(sample_snapshots[:2])},
            by_name={
                "snap1": frozenset([sample_snapshots[0]]),
                "snap2": frozenset([sample_snapshots[1]]),
            },
            is_recursive=False,
        )

        # Mark one snapshot to keep, leave others unmarked
        sample_snapshots[1].keep = True

        store.destroy(dry_run=True)

        # subprocess.run should not be called in dry run mode
        mock_run.assert_not_called()

        # Snapshots without keep=True should be marked as destroyed
        assert sample_snapshots[0].is_destroyed is True
        assert sample_snapshots[1].is_destroyed is False

    @patch("subprocess.run")
    def test_destroy_actual(self, mock_run, sample_snapshots):
        """Test destroy method in actual mode."""
        mock_run.return_value = Mock(returncode=0)

        store = ZfsSnapshotStore(
            root_dataset="pool/dataset",
            snapshots=frozenset(sample_snapshots),
            by_dataset={"pool/dataset": frozenset(sample_snapshots[:2])},
            by_name={
                "snap1": frozenset([sample_snapshots[0]]),
                "snap2": frozenset([sample_snapshots[1]]),
            },
            is_recursive=False,
        )

        # Mark one snapshot to keep
        sample_snapshots[1].keep = True

        store.destroy(dry_run=False)

        # subprocess.run should be called for snapshots not marked to keep
        mock_run.assert_called()

        # Check that the correct zfs destroy command was called
        call_args = mock_run.call_args[0][0]
        assert "zfs" in call_args
        assert "destroy" in call_args

    def test_print_summary(self, sample_snapshots, capsys):
        """Test print_summary method."""
        store = ZfsSnapshotStore(
            root_dataset="pool/dataset",
            snapshots=frozenset(sample_snapshots),
            by_dataset={"pool/dataset": frozenset(sample_snapshots[:2])},
            by_name={},
            is_recursive=False,
        )

        # Mark one snapshot to keep
        sample_snapshots[0].keep = True
        sample_snapshots[0].keep_reason = ["test reason"]

        store.print_summary()

        captured = capsys.readouterr()
        assert "Name" in captured.out
        assert "Action" in captured.out
        assert "Reason" in captured.out
        assert "keep" in captured.out
        assert "remove" in captured.out
