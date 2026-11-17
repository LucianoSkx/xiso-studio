#!/usr/bin/env python3
"""Grava as seções de metadados do AppImage (tipo 2) no ELF final.

Sem o appimagetool, o runtime vem com as seções já reservadas e vazias:
  .upd_info     texto da informação de atualização (gh-releases-zsync|...)
  .digest_md5   16 bytes do MD5 do arquivo, ignorando as seções de assinatura

Uso: patch-appimage.py <appimage> <update-info>
"""
import hashlib
import struct
import sys

SECOES_IGNORADAS = (b'.digest_md5', b'.sha256_sig', b'.sig_key')


def secoes_elf(caminho):
    """Lê a tabela de seções do ELF64 e devolve {nome: (offset, tamanho)}."""
    with open(caminho, 'rb') as f:
        dados = f.read()

    if dados[:4] != b'\x7fELF' or dados[4] != 2:
        raise SystemExit('não é um ELF64')

    shoff = struct.unpack_from('<Q', dados, 0x28)[0]
    shentsize = struct.unpack_from('<H', dados, 0x3A)[0]
    shnum = struct.unpack_from('<H', dados, 0x3C)[0]
    shstrndx = struct.unpack_from('<H', dados, 0x3E)[0]

    def cabecalho(i):
        base = shoff + i * shentsize
        nome, tipo, flags, addr, offset, tamanho = struct.unpack_from('<IIQQQQ', dados, base)
        return nome, tipo, flags, addr, offset, tamanho

    _, _, _, _, str_off, str_len = cabecalho(shstrndx)
    strings = dados[str_off:str_off + str_len]

    resultado = {}
    for i in range(shnum):
        nome_idx, _, _, _, offset, tamanho = cabecalho(i)
        fim = strings.find(b'\0', nome_idx)
        nome = strings[nome_idx:fim]
        resultado[nome] = (offset, tamanho)
    return resultado


def gravar(caminho, offset, payload):
    with open(caminho, 'r+b') as f:
        f.seek(offset)
        f.write(payload)


def main():
    if len(sys.argv) != 3:
        raise SystemExit('uso: patch-appimage.py <appimage> <update-info>')

    caminho, upd = sys.argv[1], sys.argv[2].encode()
    mapa = secoes_elf(caminho)

    # 1) informação de atualização, preenchendo o resto da seção com zeros
    off, tam = mapa.get(b'.upd_info', (0, 0))
    if not off or not tam:
        raise SystemExit('seção .upd_info ausente no runtime')
    if len(upd) + 1 > tam:
        raise SystemExit('update info não cabe na seção .upd_info')
    gravar(caminho, off, upd + b'\0' * (tam - len(upd)))

    # 2) digest MD5 do arquivo inteiro, pulando as seções que ele não cobre
    ignorar = sorted(
        (mapa[n] for n in SECOES_IGNORADAS if n in mapa and mapa[n][1]),
    )
    with open(caminho, 'rb') as f:
        dados = f.read()

    md5 = hashlib.md5()
    pos = 0
    for inicio, tamanho in ignorar:
        if inicio > pos:
            md5.update(dados[pos:inicio])
        pos = max(pos, inicio + tamanho)
    md5.update(dados[pos:])
    digest = md5.digest()

    off_md5, tam_md5 = mapa[b'.digest_md5']
    if tam_md5 < 16:
        raise SystemExit('seção .digest_md5 menor que 16 bytes')
    gravar(caminho, off_md5, digest)

    print('upd_info: %s' % upd.decode())
    print('digest_md5: %s' % digest.hex())


if __name__ == '__main__':
    main()
