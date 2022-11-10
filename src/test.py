import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles


ciphertext = [0xc, 0x6, 0x9, 0xb, 0xe, 0x9, 0xb, 0xb]
key = [0x1, 0x9, 0x1, 0x8, 0x1, 0x1, 0x1, 0x0, 0x0, 0x9, 0x0, 0x8, 0x0, 0x1, 0x0, 0x0]

@cocotb.test()
async def test_invalidopcode_simon_decrypt(dut):
    dut._log.info("start")
    clock = Clock(dut.clk, 10, units="us")
    cocotb.fork(clock.start())    
    
    # Clock in data
    dut.shift.value = 1
    dut._log.info("clock in ciphertext")
    for i in reversed(ciphertext):
        dut._log.info("Clocking in value: {}".format(i))
        dut.data_in.value = i
        await ClockCycles(dut.clk, 1)

    dut._log.info("clock in key")
    for i in reversed(key):
        dut._log.info("Clocking in value: {}".format(i))
        dut.data_in.value = i
        await ClockCycles(dut.clk, 1)

    dut.shift.value = 0
    
    await ClockCycles(dut.clk, 32)

    # dut._log.info("check all segments")
    # for i in range(10):
    #     dut._log.info("check segment {}".format(i))
    #     await ClockCycles(dut.clk, 100)
    #     assert int(dut.segments.value) == segments[i]
