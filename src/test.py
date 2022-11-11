import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

# Taken from the NSA whitepaper
ciphertext = [0xc, 0x6, 0x9, 0xb, 0xe, 0x9, 0xb, 0xb]
key = [0x1, 0x9, 0x1, 0x8, 0x1, 0x1, 0x1, 0x0, 0x0, 0x9, 0x0, 0x8, 0x0, 0x1, 0x0, 0x0]
plaintext = [0x6, 0x5, 0x6, 0x5, 0x6, 0x8, 0x7, 0x7]

@cocotb.test()
async def test_invalidopcode_simon_decrypt(dut):
    dut._log.info("Start")
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())    

    dut.shift.value = 0
    await ClockCycles(dut.clk, 2)
    
    # Clock in data
    dut.shift.value = 1
    dut._log.info("Clock in ciphertext")
    for i in reversed(ciphertext):
        dut._log.info("Clocking in value: 0x{:02X}".format(i))
        dut.data_in.value = i
        await ClockCycles(dut.clk, 1)

    dut._log.info("Clock in key")
    for i in reversed(key):
        dut._log.info("Clocking in value: 0x{:02X}".format(i))
        dut.data_in.value = i
        await ClockCycles(dut.clk, 1)

    dut.shift.value = 0
    
    # Allow for 32 rounds
    await ClockCycles(dut.clk, 32)

    dut._log.info("Check plaintext")
    dut.shift.value = 1
    for i in reversed(plaintext):
        dut._log.info("check plaintext 0x{:02X}".format(i))
        await ClockCycles(dut.clk, 1)
        assert int(dut.data_out.value) == i
