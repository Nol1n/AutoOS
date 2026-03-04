"""Speech interface module for OpenClaw.
Provides a pluggable `SpeechProvider` interface with a fake implementation.
"""
from .interface import SpeechProvider, FakeSpeechProvider

__all__ = ["SpeechProvider", "FakeSpeechProvider"]
