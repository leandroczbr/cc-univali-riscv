# Projeto RISC-V VHDL

## Como rodar

### Instalar o GHDL

```bash
sudo apt install ghdl
```

### Compilar os arquivos

```bash
ghdl -a mux5.vhd
ghdl -a mux32.vhd
ghdl -a controle.vhd
ghdl -a regmemory.vhd
ghdl -a immgen.vhd
ghdl -a ulaop.vhd
ghdl -a ula.vhd
ghdl -a design.vhd
ghdl -a testbench.vhd
```

### Executar a simulação

```bash
ghdl --elab-run testbench --vcd=wave.vcd
```

## Como abrir as ondas

### Instalar o GTKWave

```bash
sudo apt install gtkwave
```

### Abrir o arquivo de ondas

```bash
gtkwave wave.vcd
```
