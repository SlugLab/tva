import capstone
from capstone.x86 import X86_OP_IMM
from disassembler import Disassembler

class TVADisassembler(Disassembler):
  ''' TVA disassembler that disassembles bytes
      from every location an endbr64 exists at;
      all possible code that could be indirecte jumped to to
      execute is disassembled.  Overlapping instructions are
      flattened out and duplicate sequences are connected
      with jump instructions.

      Uses Capstone as its underlying linear disassembler.'''

  def __init__(self,arch):
    if arch == 'x86':
      self.md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_32)
    elif arch == 'x86-64':
      self.md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_64)
    else:
      raise NotImplementedError( 'Architecture %s is not supported'%arch )
    self.md.detail = True

  def disasm(self,bytes,base):
    JCC = ['jo','jno','js','jns','je','jz','jne','jnz','jb','jnae',
      'jc','jnb','jae','jnc','jbe','jna','ja','jnbe','jl','jnge','jge',
      'jnl','jle','jng','jg','jnle','jp','jpe','jnp','jpo','jrcxz','jecxz']

    print( 'Starting TVA disassembly...')
    dummymap = {}
    jmptrgts = []
    length = len(bytes)
    one_percent = len(bytes)//100
    thresh = 10*one_percent
    index = 0;
    for instoff in self.find_endbr(bytes, base):
      jmptrgts = [instoff]
      jtrgts = {instoff: True}
      index = 0
      if instoff > thresh:
        print( f'Disassembly {hex(instoff)}/{hex(length)} ({100*instoff//length}%) complete...')
        thresh += 10 * one_percent
      while len(jmptrgts) > index:
          instoff = jmptrgts[index]
          index += 1
          while instoff <= len(bytes):
            off = base+instoff
            try:
              if not off in dummymap: #If this offset has not been disassembled
                insts = self.md.disasm(bytes[instoff:instoff+15],base+instoff)#longest x86/x64 instr is 15 bytes
                ins = next(insts) #May raise StopIteration
                dummymap[ins.address] = True # Show that we have disassembled this address
                yield ins

                if ins.mnemonic in ['jmp','bnd jmp']: #Unconditional jump
                    op = ins.operands[0]
                    if op.type == X86_OP_IMM: # e.g. call 0xdeadbeef or jmp 0xcafebada
                      target = op.imm
                      if target not in dummymap and target not in jtrgts:
                        jmptrgts.append( target - base)
                        jtrgts[target-base] = True
                #elif ins.mnemonic in ['ret', 'bnd ret']:
                    #yield None
                    #break
                elif ins.mnemonic in JCC:
                    op = ins.operands[0]
                    target = op.imm # int(ins.op_str,16) The destination of this instruction
                    if target not in dummymap and target not in jtrgts:
                        jmptrgts.append( target - base)
                        jtrgts[target-base] = True
                instoff+=len(ins.bytes)
              else: #If this offset has already been disassembled
                yield None #Indicates we encountered this offset before
                break #Stop disassembling from this starting offset
            except StopIteration: #Not a valid instruction
              break #Stop disassembling from this starting offset
    # breaks things in python3
    #raise StopIteration

  def find_endbr(self, bytes, base):
      for x in range(0, len(bytes)):
              if bytes[x:x+4] == b"\xf3\x0f\x1e\xfa":
                yield x
