/*-
 * *****
 * Concord
 * -----
 * Copyright (C) 2017 - 2018 Walmart Inc.
 * -----
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * =====
 */

import * as React from 'react';
import { useState } from 'react';
import { connect } from 'react-redux';
import { AnyAction, Dispatch } from 'redux';
import { Input } from 'semantic-ui-react';

import { ConcordKey, RequestError } from '../../../api/common';
import { actions, State } from '../../../state/data/projects';
import { SingleOperationPopup } from '../../molecules';

interface ExternalProps {
    orgName: ConcordKey;
    projectName: ConcordKey;
    repoName: ConcordKey;
    trigger: (onClick: () => void) => React.ReactNode;
}

interface DispatchProps {
    reset: () => void;
    onConfirm: () => void;
    onDone: () => void;
}

interface StateProps {
    deleting: boolean;
    success: boolean;
    error: RequestError;
}

type Props = DispatchProps & ExternalProps & StateProps;

const DeleteRepositoryPopup = (props: Props) => {
    const { trigger, deleting, success, error, reset, onConfirm, onDone, repoName } = props;

    const [confirmation, setConfirmation] = useState('');

    return (
        <SingleOperationPopup
            trigger={trigger}
            title="Delete repository?"
            introMsg={
                <>
                    <p>
                        Are you sure you want to delete the repository? Any process or repository
                        that uses this repository may stop working correctly.
                    </p>
                    <p>
                        Please type <strong>{repoName}</strong> to confirm.
                    </p>
                    <div className={`ui input ${confirmation !== repoName ? 'error' : ''}`}>
                        <Input
                            type="text"
                            name="name"
                            placeholder="Repository name"
                            value={confirmation}
                            onChange={(e, data) => setConfirmation(data.value)}
                        />
                    </div>
                </>
            }
            running={deleting}
            runningMsg={<p>Removing the repository...</p>}
            success={success}
            successMsg={<p>The repository was removed successfully.</p>}
            error={error}
            reset={reset}
            onConfirm={onConfirm}
            onDone={onDone}
            disableYes={confirmation !== repoName}
        />
    );
};

const mapStateToProps = ({ projects }: { projects: State }): StateProps => ({
    deleting: projects.deleteRepository.running,
    success: !!projects.deleteRepository.response && projects.deleteRepository.response.ok,
    error: projects.deleteRepository.error
});

const mapDispatchToProps = (
    dispatch: Dispatch<AnyAction>,
    { orgName, projectName, repoName }: ExternalProps
): DispatchProps => ({
    reset: () => dispatch(actions.resetRepository()),
    onConfirm: () => dispatch(actions.deleteRepository(orgName, projectName, repoName)),
    onDone: () => dispatch(actions.getProject(orgName, projectName))
});

export default connect(mapStateToProps, mapDispatchToProps)(DeleteRepositoryPopup);
