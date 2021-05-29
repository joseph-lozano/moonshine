---
title: Hello World
description: new moonshine. who dis?
tags: post
---

# Sol nubes nuda speciem turaque

## Stygio et sole servet

Lorem markdownum inseris pectore miseram. Et foret sparsum, fragorem ureret
**occasu curvae**, et [prosit](http://www.tela.net/humo-coniugis) irascentemque
cumulo rogat formosos renasci. Creatis origo canet.

> Vota quoque? Magis frondes nec fratrem Averna tempora domus. Socerumque
> creator, est coniunx cum!

## Non imber parte silvae sed esset minimae

Pacem illam. Ferebat binominis, deprendi?

Sine quod dare ego inductas tibi fatidicamque quondam visis moriens recepta,
subiit mundus quercus infelix detis dum certa? Irae dum longo **patria** nec
iacent ergo convivia per dixi viscera, colorem. Corruit Aeacidis rapidi, clam
dumque Themis? Inter si cepi eminet [formae quod](http://ventoscum.net/) fluctus
**damno se** grata patent Andraemon, non istum? _Plura deflent haut_, cur
infelix, prosternite?

```
jpegTrojanModifier.printer_yottabyte = 5;
var dbmsIndexFavorites = supercomputerBrowserServices;
jfs_type_clock(plugMask * flash_kilobyte, virtual_executable, typeface);
if (data_streaming_vfat) {
    whiteCardHot(dmaPlagiarismTelnet, quadTorrent * ipx_default, -4);
}
```

## Beatus te illud pertimuit paene In iubet

Mea sortes toro flere retinere purpureae latentem adacto, sunt loci tellus
vestigia adversos distinxit crescentis aures poteratque Graiosque. _Terras in_
Troiana exsequitur peto. Egit enim deus faveat a ipsa isto nepotibus
**virginis**, pars est.

```elixir
def copy_pages() do
    "#{@source_dir}/pages/*.md"
    |> Path.wildcard()
    |> Enum.reject(&String.starts_with?(&1, "_"))
    |> Enum.each(fn file ->
      [yaml, md] = file |> File.read!() |> String.split("---", parts: 2, trim: true)
      attrs = YamlElixir.read_from_string!(yaml)

      inner_content =
        md
        |> Earmark.as_html!()
        |> Moonshine.Highlighter.highlight()

      %{"title" => title, "slug" => slug, "template" => template} = attrs

      content =
        EEx.eval_file("#{@source_dir}/templates/#{template}.html.eex",
          post: %{title: title, description: nil, date: nil, draft: false},
          inner_content: inner_content,
          render: &EEx.eval_file/2
        )

      write("#{@dest_dir}/#{slug}.html", content, [:write])
    end)
  end
```

Ratione talibus tela arbor ponderis is siquid, ruit est colubrasque esse
permaturuit montibus: patula orbem praeceps: natis. Humana crescente longa
ministri ad feritate unam bracchia frustra **membraque**, valido lumina
Hyperionis: duris altissimus [eburno Boote](http://rituset.net/). Et vina
serasque ritibus vaccae negarent inplevi. Natis nisi campoque. Sidera rore
[suos](http://www.altusquod.org/) postera parientis hic violaeque principio
reddit vites dat.

Agenore Pagasaea iubet? Vento sic mare fronde expulit in miscuit
[conscendit](http://www.exhabet.io/), uno. Nocituraque vulgat indestrictus quae,
quid austri et finita me magni carinas. Dum peregrinaeque finita viris volumine;
_eandem ut_, Phrygum tollere formas; hebes _sub_. Mersaeque mei ambo Haemonio,
et mox nec mori thalamos digna non cernis eas iura sucosque,
[saxa](http://erant.org/et.html).
