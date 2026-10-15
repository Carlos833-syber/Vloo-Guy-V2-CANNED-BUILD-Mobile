# Android (port inicial)

## Gerar o APK

O workflow **Android APK** (`.github/workflows/android.yml`) roda em pushes para
`main` e `coderabbit/android-port`, e pull requests para essas duas branches, ou manualmente em **Actions → Android APK → Run workflow**
após o workflow entrar na branch padrão. Baixe o artefato
`Vloo-Guy-Android-arm64` da execução concluída e extraia o APK.

- Android 6.0+ (API 23), dispositivo ARM64.
- APK de teste assinado com a chave de debug padrão do runner; não é uma release
  assinada para loja. Runners distintos podem gerar chaves diferentes: instalar
  uma nova build pode exigir desinstalar a anterior, apagando os saves.
- Haxe 4.3.2, Java 17, SDK/build-tools 34 e NDK 25.2.9519653.
- Dependências Haxe fixadas em `setup/setup-android.sh`; o build Android não usa
  as versões flutuantes de `hmm.json`.

Para compilar localmente, instale essas ferramentas, configure o diretório do
haxelib e execute na raiz do repositório:

```bash
bash setup/setup-android.sh
haxelib run lime config ANDROID_SDK /caminho/android-sdk
haxelib run lime config ANDROID_NDK_ROOT /caminho/android-sdk/ndk/25.2.9519653
haxelib run lime config JAVA_HOME /caminho/jdk-17
haxelib run lime config ANDROID_SETUP true
# Linux x86_64; em outros sistemas use a pasta correspondente em NDK/toolchains/llvm/prebuilt.
haxelib run lime config ANDROID_HOST linux-x86_64
haxelib run lime config HXCPP_STRIP /caminho/android-sdk/ndk/25.2.9519653/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip
haxelib run lime build android -DHXCPP_COMPILE_THREADS=2
```

## Conteúdo e controles

Os arquivos de `example_mods` são incluídos no APK e extraídos para o armazenamento
privado do aplicativo antes do jogo iniciar. Não precisa conceder acesso geral ao
armazenamento nem copiar os mods manualmente. A instalação inicial extrai cerca
de 217 MB e pode demorar; reserve espaço para o APK e os arquivos extraídos.
O manifesto de conteúdo evita repetir a extração quando nada mudou. Builds com
conteúdo alterado substituem os arquivos empacotados, preservando saves e outros
arquivos. Não edite os arquivos empacotados esperando preservá-los numa atualização.

Quatro áreas inferiores controlam as notas e as direções dos menus. Os botões
**OK**, **BACK** e **PAUSE** usam as teclas configuradas do jogo. Há suporte a
múltiplos dedos, notas longas e arrastar entre direções. Controles externos
continuam disponíveis.

Lua está habilitado no Android. O único stage HScript incluído no mod,
`performance`, usa uma versão Lua equivalente apenas no APK. HScript de mods
adicionais não está habilitado nessa configuração Android.

## Validação e limites

O workflow executa `bash tests/run-assets.sh` antes de compilar. Os testes usam os
carregadores reais de JSON com assets registrados apenas em memória e uma pasta
temporária como armazenamento do aplicativo. Verificam personagens e cenários
empacotados, prioridade dos mods, fallback para BF e arquivos soltos do desktop,
com mods habilitados, como na build Android. Podem ser executados localmente após instalar
as dependências de `setup/setup-android.sh`.

Essa validação não executa gráficos, áudio ou Lua no Android e não confirma que
todos os fechamentos ao selecionar músicas foram resolvidos no aparelho.

A checagem de tipos Haxe e a compilação nativa C++/Gradle passaram com as
dependências fixadas. O [workflow de 15/10/2026](https://github.com/Carlos833-syber/Vloo-Guy-V2-CANNED-BUILD-Mobile/actions/runs/38663504377)
gerou o APK de teste ARM64 (aproximadamente 570 MiB). A integridade ZIP e a
arquitetura ARM64 das quatro bibliotecas nativas foram verificadas. O APK ainda
precisa ser testado em aparelho quanto a abertura, áudio, vídeos, shaders, multitouch, pausa,
retorno do segundo plano, conclusão de músicas e armazenamento dos saves.

A build original incompleta lista `chronology`, `lurking`, `blunted` e `nightmare`
sem charts nem instrumental correspondentes. Algumas músicas também não têm todas
as dificuldades anunciadas. O port não recria esse conteúdo; selecionar entradas
incompletas pode falhar. Não publique como versão completa sem revisar essas listas
ou adicionar os arquivos originais.
