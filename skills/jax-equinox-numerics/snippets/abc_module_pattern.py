import abc
import equinox as eqx
from typing import Generic, TypeVar
from jaxtyping import Array, PyTree


_State = TypeVar("_State")


class AbstractSolver(eqx.Module, Generic[_State]):
    rtol: eqx.AbstractVar[float]

    @abc.abstractmethod
    def init(self, y: PyTree[Array]) -> _State: ...

    @abc.abstractmethod
    def step(self, y: PyTree[Array], state: _State) -> tuple[PyTree[Array], _State]: ...


class MySolver(AbstractSolver[dict]):
    rtol: float

    def init(self, y):
        return {"count": 0}

    def step(self, y, state):
        return y, {"count": state["count"] + 1}
