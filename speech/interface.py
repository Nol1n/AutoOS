from typing import Protocol


class SpeechProvider(Protocol):
    def start_listening(self) -> None:
        ...

    def stop_listening(self) -> None:
        ...

    def transcribe(self) -> str:
        ...


class FakeSpeechProvider:
    def start_listening(self) -> None:
        pass

    def stop_listening(self) -> None:
        pass

    def transcribe(self) -> str:
        return "(fake) hello world"
