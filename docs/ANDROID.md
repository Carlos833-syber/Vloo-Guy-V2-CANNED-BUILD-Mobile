# Android (port inicial)

## Gerar o APK

O workflow **Android APK** (`.github/workflows/android.yml`) roda em pushes e
pull requests para `main`, ou manualmente em **Actions → Android APK → Run workflow**
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
haxelib run lime build android -arm64 -DHXCPP_COMPILE_THREADS=2
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

A checagem de tipos Haxe para o alvo Android passou com as dependências fixadas.
Isso não substitui a compilação C++/Gradle nem o teste no dispositivo. O APK ainda
precisa ser validado quanto a abertura, áudio, vídeos, shaders, multitouch, pausa,
retorno do segundo plano, conclusão de músicas e armazenamento dos saves.

A build original incompleta lista `chronology`, `lurking`, `blunted` e `nightmare`
sem charts nem instrumental correspondentes. Algumas músicas também não têm todas
as dificuldades anunciadas. O port não recria esse conteúdo; selecionar entradas
incompletas pode falhar. Não publique como versão completa sem revisar essas listas
ou adicionar os arquivos originais.
