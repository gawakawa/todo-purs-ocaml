import { Container, getContainer } from "@cloudflare/containers";

export class Backend extends Container {
  defaultPort = 8080;
  sleepAfter = "10m";
}

export default {
  async fetch(request, env) {
    return getContainer(env.BACKEND).fetch(request);
  },
};
