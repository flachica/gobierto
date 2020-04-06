<template>
  <div class="gobierto-data-sql-editor-tabs">
    <div class="pure-g">
      <div
        class="pure-u-1"
        style="text-align: right; margin-bottom: 1rem"
      >
        <SaveChartButton />
        <keep-alive>
          <DownloadButton
            :editor="true"
            :array-formats="arrayFormats"
            :class="[directionLeft ? 'modal-left' : 'modal-right']"
            style="display: inline-block"
            class="arrow-top"
          />
        </keep-alive>
      </div>
    </div>

    <div class="gobierto-data-visualization--aspect-ratio-16-9">
      <Visualizations :items="items" />
    </div>
  </div>
</template>
<script>
import DownloadButton from "./../../commons/DownloadButton.vue";
import SaveChartButton from "./../../commons/SaveChartButton.vue";
import Visualizations from "./../../commons/Visualizations.vue";
import { getUserId } from "./../../../../lib/helpers";
import { VisualizationFactoryMixin } from "./../../../../lib/factories/visualizations";

export default {
  name: "SQLEditorResults",
  components: {
    Visualizations,
    DownloadButton,
    SaveChartButton
  },
  mixins: [VisualizationFactoryMixin],
  props: {
    activeTab: {
      type: Number,
      default: 0
    },
    privateQueries: {
      type: Array,
      required: true
    },
    arrayFormats: {
      type: Object,
      required: true
    },
    items: {
      type: Array,
      default: () => []
    },
    tableName: {
      type: String,
      required: true
    },
    datasetId: {
      type: Number,
      required: true
    },
    currentQuery: {
      type: String,
      default: ""
    }
  },
  data() {
    return {
      labelTable: "",
      labelVisualization: "",
      directionLeft: false,
      privateQuery: false,
      editorFocus: false
    };
  },
  created() {
    this.labelTable = I18n.t("gobierto_data.projects.table");
    this.labelVisualization = I18n.t("gobierto_data.projects.visualization");

    this.userId = getUserId();
    this.noLogin = this.userId === "" ? true : false;

    this.$root.$on("saveVisualization", this.saveVisualization);
  },
  beforeDestroy() {
    this.$root.$off("saveVisualization", this.saveVisualization);
  },
  methods: {
    saveVisualization(config, opts) {
      if (this.noLogin) this.goToLogin();

      const { name, privacy } = opts;

      // default attributes
      let attributes = {
        name_translations: {
          en: name,
          es: name
        },
        privacy_status: privacy ? "closed" : "open",
        spec: config,
        user_id: this.userId,
        dataset_id: this.datasetId,
      };

      // Get the id if the query matches with a stored query
      const { id } =
        this.privateQueries.find(
          ({ attributes }) =>
            attributes.sql === decodeURIComponent(this.currentQuery).trim()
        ) || {};

      // Depending whether the query was stored in database or not,
      // we must save the query_id or the query, instead
      if (id) {
        attributes = { ...attributes, query_id: id };
      } else {
        attributes = { ...attributes, sql: this.currentQuery };
      }

      // POST data obj
      const data = {
        data: {
          type: "gobierto_data-visualizations",
          attributes
        }
      };

      this.postVisualization(data)
        .then(() => {
          // TODO: send a message about OK response
        })
        .catch(error => {
          const messageError = error.response;
          console.error(messageError);
        });
    },
    goToLogin() {
      location.href = "/user/sessions/new?open_modal=true";
    }
  }
};
</script>