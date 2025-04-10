/*
  This file is part of Edgehog.

  Copyright 2021-2025 SECO Mind Srl

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

  SPDX-License-Identifier: Apache-2.0
*/

import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { RelayEnvironmentProvider } from "react-relay/hooks";
import { BrowserRouter as RouterProvider } from "react-router-dom";

import { fetchGraphQL, relayEnvironment } from "api";
import SessionProvider, { useSession } from "contexts/Session";
import AuthProvider from "contexts/Auth";
import I18nProvider from "i18n";
import App from "./App";
import "./index.scss";

function RelayProvider({ children }: { children: React.ReactNode }) {
  const { session } = useSession();

  return (
    <RelayEnvironmentProvider environment={relayEnvironment(session)}>
      {children}
    </RelayEnvironmentProvider>
  );
}

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <SessionProvider>
      <RelayProvider>
        <AuthProvider fetchGraphQL={fetchGraphQL}>
          <RouterProvider>
            <I18nProvider>
              <App />
            </I18nProvider>
          </RouterProvider>
        </AuthProvider>
      </RelayProvider>
    </SessionProvider>
  </StrictMode>,
);
