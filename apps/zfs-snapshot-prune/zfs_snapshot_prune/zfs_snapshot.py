from __future__ import annotations

import logging
from dataclasses import dataclass, field
from typing import TYPE_CHECKING, final, override

if TYPE_CHECKING:
    from datetime import datetime

logger = logging.getLogger(__name__)


@final
@dataclass(frozen=False, unsafe_hash=False, order=False)
class ZfsSnapshot:
    name: str  # e.g. dataset@snapshotname
    dataset: str
    snapshot_name: str
    created: datetime  # localtimezone+offset
    keep_reason: list[str] = field(
        default_factory=list
    )  # 해당 snapshot 을 보존한다면 그 이유들

    @override
    def __str__(self) -> str:
        return self.name

    @override
    def __hash__(self):
        return self.name.__hash__()

    @override
    def __eq__(self, other: object) -> bool:
        if not isinstance(other, ZfsSnapshot):
            msg = "Cannot compare ZfsSnapshot with non-ZfsSnapshot"
            raise TypeError(msg)

        return self.name == other.name

    def __lt__(self, other: object) -> bool:
        if not isinstance(other, ZfsSnapshot):
            msg = "Cannot compare ZfsSnapshot with non-ZfsSnapshot"
            raise TypeError(msg)

        if self.dataset != other.dataset:
            msg = "Cannot compare ZfsSnapshot of different datasets"
            raise ValueError(msg)

        return self.created < other.created
