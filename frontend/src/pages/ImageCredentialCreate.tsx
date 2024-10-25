/*
  This file is part of Edgehog.

  Copyright 2024 SECO Mind Srl

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

import { ReactNode, useCallback, useState } from "react";
import { FormattedMessage } from "react-intl";
import { graphql, useMutation } from "react-relay/hooks";

import type { ImageCredentialCreate_imageCredentialCreate_Mutation } from "api/__generated__/ImageCredentialCreate_imageCredentialCreate_Mutation.graphql";
import Alert from "components/Alert";
import Page from "components/Page";
import CreateImageCredentialForm from "forms/CreateImageCredential";
import { Route, useNavigate } from "Navigation";
import type { CreateImageCredential } from "types/ImageCredential";

const { imageCredentials } = Route;
const { Header, Main } = Page;

const CREATE_IMAGE_CREDENTIAL_MUTATION = graphql`
  mutation ImageCredentialCreate_imageCredentialCreate_Mutation(
    $input: CreateImageCredentialsInput!
  ) {
    createImageCredentials(input: $input) {
      result {
        id
      }
    }
  }
`;

const ImageCredentialCreatePage = () => {
  const [errorFeedback, setErrorFeedback] = useState<ReactNode>(null);
  const navigate = useNavigate();

  const [createImageCredential, isCreatingImageCredential] =
    useMutation<ImageCredentialCreate_imageCredentialCreate_Mutation>(
      CREATE_IMAGE_CREDENTIAL_MUTATION,
    );

  const handleCreateImageCredential = useCallback(
    (imageCredential: CreateImageCredential) => {
      createImageCredential({
        variables: { input: imageCredential },
        onCompleted(data, errors) {
          const ImageCredentialId = data.createImageCredentials?.result?.id;
          if (ImageCredentialId) {
            return navigate({
              route: imageCredentials,
            });
          }
          if (errors) {
            const errorFeedback = errors
              .map(({ fields, message }) =>
                fields.length ? `${fields.join(" ")} ${message}` : message,
              )
              .join(". \n");
            return setErrorFeedback(errorFeedback);
          }
        },
        onError() {
          setErrorFeedback(
            <FormattedMessage
              id="pages.ImageCredentialCreate.creationErrorFeedback"
              defaultMessage="Could not create the group, please try again."
            />,
          );
        },
      });
    },
    [createImageCredential, navigate],
  );

  return (
    <Page>
      <Header
        title={<FormattedMessage id="pages.ImageCredentialCreate.title" />}
      />
      <Main>
        <Alert
          show={!!errorFeedback}
          variant="danger"
          onClose={() => setErrorFeedback(null)}
          dismissible
        >
          {errorFeedback}
        </Alert>
        <CreateImageCredentialForm
          onSubmit={handleCreateImageCredential}
          isLoading={isCreatingImageCredential}
        />
      </Main>
    </Page>
  );
};

export default ImageCredentialCreatePage;
