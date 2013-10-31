CELLBASE_HOST = "http://ws-beta.bioinfo.cipf.es/cellbase-server-3.0.0/rest";
CELLBASE_VERSION = "v3";
SEQUENCE_COLORS = {A: "#009900", C: "#0000FF", G: "#857A00", T: "#aa0000", N: "#555555"};

GENE_BIOTYPE_COLORS = {
    "3prime_overlapping_ncrna": "Orange",
    "ambiguous_orf": "SlateBlue",
    "antisense": "SteelBlue",
    "disrupted_domain": "YellowGreen",
    "IG_C_gene": "#FF7F50",
    "IG_D_gene": "#FF7F50",
    "IG_J_gene": "#FF7F50",
    "IG_V_gene": "#FF7F50",
    "lincRNA": "#8b668b",
    "miRNA": "#8b668b",
    "misc_RNA": "#8b668b",
    "Mt_rRNA": "#8b668b",
    "Mt_tRNA": "#8b668b",
    "ncrna_host": "Fuchsia",
    "nonsense_mediated_decay": "seagreen",
    "non_coding": "orangered",
    "non_stop_decay": "aqua",
    "polymorphic_pseudogene": "#666666",
    "processed_pseudogene": "#666666",
    "processed_transcript": "#0000ff",
    "protein_coding": "#a00000",
    "pseudogene": "#666666",
    "retained_intron": "goldenrod",
    "retrotransposed": "lightsalmon",
    "rRNA": "indianred",
    "sense_intronic": "#20B2AA",
    "sense_overlapping": "#20B2AA",
    "snoRNA": "#8b668b",
    "snRNA": "#8b668b",
    "transcribed_processed_pseudogene": "#666666",
    "transcribed_unprocessed_pseudogene": "#666666",
    "unitary_pseudogene": "#666666",
    "unprocessed_pseudogene": "#666666",
    "": "orangered",
    "other": "#000000"
};

FEATURE_CONFIG = {
    gene: {
        filters: [
            {
                name: "biotype",
                text: "Biotype",
                values: ["3prime_overlapping_ncrna", "ambiguous_orf", "antisense", "disrupted_domain", "IG_C_gene", "IG_D_gene", "IG_J_gene", "IG_V_gene", "lincRNA", "miRNA", "misc_RNA", "Mt_rRNA", "Mt_tRNA", "ncrna_host", "nonsense_mediated_decay", "non_coding", "non_stop_decay", "polymorphic_pseudogene", "processed_pseudogene", "processed_transcript", "protein_coding", "pseudogene", "retained_intron", "retrotransposed", "rRNA", "sense_intronic", "sense_overlapping", "snoRNA", "snRNA", "transcribed_processed_pseudogene", "transcribed_unprocessed_pseudogene", "unitary_pseudogene", "unprocessed_pseudogene"],
                selection: "multi"
            }
        ]
    }
};

FEATURE_TYPES = {
    formatTitle: function (str) {
        var s = str.replace(/_/gi, " ");
        s = s.charAt(0).toUpperCase() + s.slice(1);
        return s;
    },
    getTipCommons: function (f) {
        var strand = (f.strand != null) ? f.strand : "NA";
        return 'start-end:&nbsp;<span class="emph">' + f.start + '-' + f.end + '</span><br>' +
            'strand:&nbsp;<span class="emph">' + strand + '</span><br>' +
            'length:&nbsp;<span class="info">' + (f.end - f.start + 1).toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,") + '</span><br>';
    },

    gene: {
        label: function (f, zoom) {
            var name = (f.name != null) ? f.name : f.id;
            var str = "";
            str += (f.strand < 0 || f.strand == '-') ? "<" : "";
            str += " " + name + " ";
            str += (f.strand > 0 || f.strand == '+') ? ">" : "";
            if (f.biotype != null && f.biotype != '' && zoom > 25) {
                str += " [" + f.biotype + "]";
            }
            return str;
        },
        tooltipTitle: function (f) {
            var name = (f.name != null) ? f.name : f.id;
            return FEATURE_TYPES.formatTitle('Gene') +
                ' - <span class="ok">' + name + '</span>';
        },
        tooltipText: function (f) {
            var color = GENE_BIOTYPE_COLORS[f.biotype];
            return    'id:&nbsp;<span class="ssel">' + f.id + '</span><br>' +
                'biotype:&nbsp;<span class="emph" style="color:' + color + ';">' + f.biotype + '</span><br>' +
                FEATURE_TYPES.getTipCommons(f) +
                'source:&nbsp;<span class="ssel">' + f.source + '</span><br><br>' +
                'description:&nbsp;<span class="emph">' + f.description + '</span><br>';
        },
        color: function (f) {
            return GENE_BIOTYPE_COLORS[f.biotype];
        },
        infoWidgetId: "id",
        height: 4,
        histogramColor: "lightblue"
    },
    feature: {
        label: function (f, zoom) {
        	return f.id;
        },
    	infoWidgetId: "id",
        height: 4,
        histogramColor: "green"
    }
}