# Combat Library

Projeto Lua para Roblox organizado para hospedagem no GitHub.

## Estrutura

```text
CombatLibrary/
├── CombatLibrary.lua   # Script principal
├── README.md           # Informações do projeto
└── LICENSE             # Licença (opcional)
```

## Hospedagem no GitHub

1. Crie um novo repositório no GitHub.
2. Envie os arquivos desta pasta.
3. Mantenha `CombatLibrary.lua` na raiz do repositório.
4. Para obter o conteúdo bruto, abra o arquivo no GitHub e use a opção `Raw`.

## Loader genérico

Depois de hospedar, o padrão de carregamento pode usar o link raw do arquivo:

```lua
loadstring(game:HttpGet("SEU_LINK_RAW_AQUI", true))()
```

Substitua apenas pelo link raw gerado pelo seu próprio repositório.
