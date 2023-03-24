import random

import ./neuron


const
    base = 0.88
    width = 0.24  # upper bound minus lower bound of the uniform random variable


type
    Synapse* = tuple
        V_rp: float   # 0 AMPA, -1.1 for GABA
        gamma: float  # it looks like anything from 0.6 to 0.96 is used in RTB 2004
        w: float      # set this to 1 for testing? then a spike would approximately double the conductance
        g: float
        I_syn: float


proc step*(s: Synapse, preSpike: bool, postV: float): Synapse =
    (
        V_rp: s.V_rp,
        gamma: s.gamma,
        w: s.w,
        g: (if preSpike:
            s.gamma * s.g + (base + rand(width)) * s.g / s.w
        else:
            s.gamma * s.g),
        I_syn: -s.g * (postV - s.V_rp)
    )


proc step*(synapses: var openArray[seq[Synapse]]; pre, post: var openArray[Neuron]; I_exts: openArray[float]): seq[float] =
    # first call step() on pre, so can check if they are spiking
    # post has not yet step'd, so can check V_n
    # return the I_exts for the post layer, we assume that this is just the sum of I_syns
    step(pre, I_exts)
    result = newSeq[float](post.len)
    for preIdx in 0 ..< synapses.len:
        for postIdx in 0 ..< synapses[preIdx].len:
            synapses[preIdx][postIdx] = step(synapses[preIdx][postIdx], pre[preIdx].spike, post[postIdx].V_n)
            result[postIdx] += synapses[preIdx][postIdx].I_syn
